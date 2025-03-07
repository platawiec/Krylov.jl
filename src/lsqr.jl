# An implementation of LSQR for the solution of the
# over-determined linear least-squares problem
#
#  minimize ‖Ax - b‖₂
#
# equivalently, of the normal equations
#
#  AᵀAx = Aᵀb.
#
# LSQR is formally equivalent to applying the conjugate gradient method
# to the normal equations but should be more stable. It is also formally
# equivalent to CGLS though LSQR should be expected to be more stable on
# ill-conditioned or poorly scaled problems.
#
# This implementation follows the original implementation by
# Michael Saunders described in
#
# C. C. Paige and M. A. Saunders, LSQR: An Algorithm for Sparse Linear
# Equations and Sparse Least Squares, ACM Transactions on Mathematical
# Software, 8(1), pp. 43--71, 1982.
#
# Dominique Orban, <dominique.orban@gerad.ca>
# Montreal, QC, May 2015.

export lsqr, lsqr!


"""
    (x, stats) = lsqr(A, b::AbstractVector{T};
                      M=I, N=I, sqd::Bool=false,
                      λ::T=zero(T), axtol::T=√eps(T), btol::T=√eps(T),
                      atol::T=zero(T), rtol::T=zero(T),
                      etol::T=√eps(T), window::Int=5,
                      itmax::Int=0, conlim::T=1/√eps(T),
                      radius::T=zero(T), verbose::Int=0, history::Bool=false) where T <: AbstractFloat

Solve the regularized linear least-squares problem

    minimize ‖b - Ax‖₂² + λ²‖x‖₂²

using the LSQR method, where λ ≥ 0 is a regularization parameter.
LSQR is formally equivalent to applying CG to the normal equations

    (AᵀA + λ²I) x = Aᵀb

(and therefore to CGLS) but is more stable.

LSQR produces monotonic residuals ‖r‖₂ but not optimality residuals ‖Aᵀr‖₂.
It is formally equivalent to CGLS, though can be slightly more accurate.

Preconditioners M and N may be provided in the form of linear operators and are
assumed to be symmetric and positive definite. If `sqd` is set to `true`,
we solve the symmetric and quasi-definite system

    [ E    A ] [ r ]   [ b ]
    [ Aᵀ  -F ] [ x ] = [ 0 ],

where E and F are symmetric and positive definite.
The system above represents the optimality conditions of

    minimize ‖b - Ax‖²_E⁻¹ + ‖x‖²_F.

For a symmetric and positive definite matrix `K`, the K-norm of a vector `x` is `‖x‖²_K = xᵀKx`.
LSQR is then equivalent to applying CG to `(AᵀE⁻¹A + F)x = AᵀE⁻¹b` with `r = E⁻¹(b - Ax)`.
Preconditioners M = E⁻¹ ≻ 0 and N = F⁻¹ ≻ 0 may be provided in the form of linear operators.

If `sqd` is set to `false` (the default), we solve the symmetric and
indefinite system

    [ E    A ] [ r ]   [ b ]
    [ Aᵀ   0 ] [ x ] = [ 0 ].

The system above represents the optimality conditions of

    minimize ‖b - Ax‖²_E⁻¹.

In this case, `N` can still be specified and indicates the weighted norm in which `x` and `Aᵀr` should be measured.
`r` can be recovered by computing `E⁻¹(b - Ax)`.

#### Reference

* C. C. Paige and M. A. Saunders, [*LSQR: An Algorithm for Sparse Linear Equations and Sparse Least Squares*](https://doi.org/10.1145/355984.355989), ACM Transactions on Mathematical Software, 8(1), pp. 43--71, 1982.
"""
function lsqr(A, b :: AbstractVector{T}; window :: Int=5, kwargs...) where T <: AbstractFloat
  solver = LsqrSolver(A, b, window=window)
  lsqr!(solver, A, b; kwargs...)
  return (solver.x, solver.stats)
end

"""
    solver = lsqr!(solver::LsqrSolver, args...; kwargs...)

where `args` and `kwargs` are arguments and keyword arguments of [`lsqr`](@ref).

See [`LsqrSolver`](@ref) for more details about the `solver`.
"""
function lsqr!(solver :: LsqrSolver{T,S}, A, b :: AbstractVector{T};
               M=I, N=I, sqd :: Bool=false,
               λ :: T=zero(T), axtol :: T=√eps(T), btol :: T=√eps(T),
               atol :: T=zero(T), rtol :: T=zero(T),
               etol :: T=√eps(T), itmax :: Int=0, conlim :: T=1/√eps(T),
               radius :: T=zero(T), verbose :: Int=0, history :: Bool=false) where {T <: AbstractFloat, S <: DenseVector{T}}

  m, n = size(A)
  length(b) == m || error("Inconsistent problem size")
  (verbose > 0) && @printf("LSQR: system of %d equations in %d variables\n", m, n)

  # Tests M = Iₙ and N = Iₘ
  MisI = (M === I)
  NisI = (N === I)

  # Check type consistency
  eltype(A) == T || error("eltype(A) ≠ $T")
  ktypeof(b) == S || error("ktypeof(b) ≠ $S")

  # Compute the adjoint of A
  Aᵀ = A'

  # Set up workspace.
  allocate_if(!MisI, solver, :u, S, m)
  allocate_if(!NisI, solver, :v, S, n)
  x, Nv, Aᵀu, w = solver.x, solver.Nv, solver.Aᵀu, solver.w
  Mu, Av, err_vec, stats = solver.Mu, solver.Av, solver.err_vec, solver.stats
  rNorms, ArNorms = stats.residuals, stats.Aresiduals
  reset!(stats)
  u = MisI ? Mu : solver.u
  v = NisI ? Nv : solver.v

  # If solving an SQD system, set regularization to 1.
  sqd && (λ = one(T))
  λ² = λ * λ
  ctol = conlim > 0 ? 1/conlim : zero(T)
  x .= zero(T)

  # Initialize Golub-Kahan process.
  # β₁ M u₁ = b.
  Mu .= b
  MisI || mul!(u, M, Mu)
  β₁ = sqrt(@kdot(m, u, Mu))
  if β₁ == 0
    stats.solved, stats.inconsistent = true, false
    stats.status = "x = 0 is a zero-residual solution"
    history && push!(rNorms, zero(T))
    history && push!(ArNorms, zero(T))
    return solver
  end
  β = β₁

  @kscal!(m, one(T)/β₁, u)
  MisI || @kscal!(m, one(T)/β₁, Mu)
  mul!(Aᵀu, Aᵀ, u)
  Nv .= Aᵀu
  NisI || mul!(v, N, Nv)
  Anorm² = @kdot(n, v, Nv)
  Anorm = sqrt(Anorm²)
  α = Anorm
  Acond  = zero(T)
  xNorm  = zero(T)
  xNorm² = zero(T)
  dNorm² = zero(T)
  c2 = -one(T)
  s2 = zero(T)
  z  = zero(T)

  xENorm² = zero(T)
  err_lbnd = zero(T)
  window = length(err_vec)
  err_vec .= zero(T)

  iter = 0
  itmax == 0 && (itmax = m + n)

  (verbose > 0) && @printf("%5s  %7s  %7s  %7s  %7s  %7s  %7s  %7s  %7s\n", "k", "α", "β", "‖r‖", "‖Aᵀr‖", "compat", "backwrd", "‖A‖", "κ(A)")
  display(iter, verbose) && @printf("%5d  %7.1e  %7.1e  %7.1e  %7.1e  %7.1e  %7.1e  %7.1e  %7.1e\n", iter, β₁, α, β₁, α, 0, 1, Anorm, Acond)

  rNorm = β₁
  r1Norm = rNorm
  r2Norm = rNorm
  res2   = zero(T)
  history && push!(rNorms, r2Norm)
  ArNorm = ArNorm0 = α * β
  history && push!(ArNorms, ArNorm)
  # Aᵀb = 0 so x = 0 is a minimum least-squares solution
  if α == 0
    stats.solved, stats.inconsistent = true, false
    stats.status = "x = 0 is a minimum least-squares solution"
    return solver
  end
  @kscal!(n, one(T)/α, v)
  NisI || @kscal!(n, one(T)/α, Nv)
  w .= v

  # Initialize other constants.
  ϕbar = β₁
  ρbar = α
  # θ = 0.0

  status = "unknown"
  on_boundary = false
  solved_lim = ArNorm / (Anorm * rNorm) ≤ axtol
  solved_mach = one(T) + ArNorm / (Anorm * rNorm) ≤ one(T)
  solved = solved_mach | solved_lim
  tired  = iter ≥ itmax
  ill_cond = ill_cond_mach = ill_cond_lim = false
  zero_resid_lim = rNorm / β₁ ≤ axtol
  zero_resid_mach = one(T) + rNorm / β₁ ≤ one(T)
  zero_resid = zero_resid_mach | zero_resid_lim
  fwd_err = false

  while ! (solved || tired || ill_cond)
    iter = iter + 1

    # Generate next Golub-Kahan vectors.
    # 1. βₖ₊₁Muₖ₊₁ = Avₖ - αₖMuₖ
    mul!(Av, A, v)
    @kaxpby!(m, one(T), Av, -α, Mu)
    MisI || mul!(u, M, Mu)
    β = sqrt(@kdot(m, u, Mu))
    if β ≠ 0
      @kscal!(m, one(T)/β, u)
      MisI || @kscal!(m, one(T)/β, Mu)
      Anorm² = Anorm² + α * α + β * β  # = ‖B_{k-1}‖²
      λ > 0 && (Anorm² += λ²)

      # 2. αₖ₊₁Nvₖ₊₁ = Aᵀuₖ₊₁ - βₖ₊₁Nvₖ
      mul!(Aᵀu, Aᵀ, u)
      @kaxpby!(n, one(T), Aᵀu, -β, Nv)
      NisI || mul!(v, N, Nv)
      α = sqrt(@kdot(n, v, Nv))
      if α ≠ 0
        @kscal!(n, one(T)/α, v)
        NisI || @kscal!(n, one(T)/α, Nv)
      end
    end

    # Continue QR factorization
    # 1. Eliminate the regularization parameter.
    (c1, s1, ρbar1) = sym_givens(ρbar, λ)
    ψ = s1 * ϕbar
    ϕbar = c1 * ϕbar

    # 2. Eliminate β.
    # Q [ Lₖ  β₁ e₁ ] = [ Rₖ   zₖ  ] :
    #   [ β    0    ]   [ 0   ζbar ]
    #
    #       k  k+1    k    k+1      k  k+1
    # k   [ c   s ] [ ρbar    ] = [ ρ  θ⁺    ]
    # k+1 [ s  -c ] [ β    α⁺ ]   [    ρbar⁺ ]
    #
    # so that we obtain
    #
    # [ c  s ] [ ζbar ] = [ ζ     ]
    # [ s -c ] [  0   ]   [ ζbar⁺ ]
    (c, s, ρ) = sym_givens(ρbar1, β)
    ϕ = c * ϕbar
    ϕbar = s * ϕbar

    xENorm² = xENorm² + ϕ * ϕ
    err_vec[mod(iter, window) + 1] = ϕ
    iter ≥ window && (err_lbnd = norm(err_vec))

    τ = s * ϕ
    θ = s * α
    ρbar = -c * α
    dNorm² += @kdot(n, w, w) / ρ^2

    # if a trust-region constraint is give, compute step to the boundary
    # the step ϕ/ρ is not necessarily positive
    σ = ϕ / ρ
    if radius > 0
      t1, t2 = to_boundary(x, w, radius)
      tmax, tmin = max(t1, t2), min(t1, t2)
      on_boundary = σ > tmax || σ < tmin
      σ = σ > 0 ? min(σ, tmax) : max(σ, tmin)
    end

    @kaxpy!(n, σ, w, x)  # x = x + ϕ / ρ * w
    @kaxpby!(n, one(T), v, -θ/ρ, w)  # w = v - θ / ρ * w

    # Use a plane rotation on the right to eliminate the super-diagonal
    # element (θ) of the upper-bidiagonal matrix.
    # Use the result to estimate norm(x).
    δ = s2 * ρ
    γbar = -c2 * ρ
    rhs = ϕ - δ * z
    zbar = rhs / γbar
    xNorm = sqrt(xNorm² + zbar * zbar)
    (c2, s2, γ) = sym_givens(γbar, θ)
    z = rhs / γ
    xNorm² += z * z

    Anorm = sqrt(Anorm²)
    Acond = Anorm * sqrt(dNorm²)
    res1  = ϕbar * ϕbar
    res2 += ψ * ψ
    rNorm = sqrt(res1 + res2)

    ArNorm = α * abs(τ)
    history && push!(ArNorms, ArNorm)

    r1sq = rNorm * rNorm - λ² * xNorm²
    r1Norm = sqrt(abs(r1sq))
    r1sq < 0 && (r1Norm = -r1Norm)
    r2Norm = rNorm
    history && push!(rNorms, r2Norm)

    test1 = rNorm / β₁
    test2 = ArNorm / (Anorm * rNorm)
    test3 = 1 / Acond
    t1    = test1 / (one(T) + Anorm * xNorm / β₁)
    rNormtol = btol + axtol * Anorm * xNorm / β₁

    display(iter, verbose) && @printf("%5d  %7.1e  %7.1e  %7.1e  %7.1e  %7.1e  %7.1e  %7.1e  %7.1e\n", iter, α, β, rNorm, ArNorm, test1, test2, Anorm, Acond)

    # Stopping conditions that do not depend on user input.
    # This is to guard against tolerances that are unreasonably small.
    ill_cond_mach = (one(T) + test3 ≤ one(T))
    solved_mach = (one(T) + test2 ≤ one(T))
    zero_resid_mach = (one(T) + t1 ≤ one(T))

    # Stopping conditions based on user-provided tolerances.
    tired  = iter ≥ itmax
    ill_cond_lim = (test3 ≤ ctol)
    solved_lim = (test2 ≤ axtol)
    solved_opt = ArNorm ≤ atol + rtol * ArNorm0
    zero_resid_lim = (test1 ≤ rNormtol)
    iter ≥ window && (fwd_err = err_lbnd ≤ etol * sqrt(xENorm²))

    ill_cond = ill_cond_mach | ill_cond_lim
    zero_resid = zero_resid_mach | zero_resid_lim
    solved = solved_mach | solved_lim | solved_opt | zero_resid | fwd_err | on_boundary
  end
  (verbose > 0) && @printf("\n")

  tired         && (status = "maximum number of iterations exceeded")
  ill_cond_mach && (status = "condition number seems too large for this machine")
  ill_cond_lim  && (status = "condition number exceeds tolerance")
  solved        && (status = "found approximate minimum least-squares solution")
  zero_resid    && (status = "found approximate zero-residual solution")
  fwd_err       && (status = "truncated forward error small enough")
  on_boundary   && (status = "on trust-region boundary")

  # Update stats
  stats.solved = solved
  stats.inconsistent = !zero_resid
  stats.status = status
  return solver
end
