# An implementation of BiLQ for the solution of unsymmetric
# and square consistent linear system Ax = b.
#
# This method is described in
#
# A. Montoison and D. Orban
# BiLQ: An Iterative Method for Nonsymmetric Linear Systems with a Quasi-Minimum Error Property.
# SIAM Journal on Matrix Analysis and Applications, 41(3), pp. 1145--1166, 2020.
#
# Alexis Montoison, <alexis.montoison@polymtl.ca>
# Montreal, February 2019.

export bilq, bilq!

"""
    (x, stats) = bilq(A, b::AbstractVector{T}; c::AbstractVector{T}=b,
                      atol::T=√eps(T), rtol::T=√eps(T), transfer_to_bicg::Bool=true,
                      itmax::Int=0, verbose::Int=0, history::Bool=false) where T <: AbstractFloat

Solve the square linear system Ax = b using the BiLQ method.

BiLQ is based on the Lanczos biorthogonalization process and requires two initial vectors `b` and `c`.
The relation `bᵀc ≠ 0` must be satisfied and by default `c = b`.
When `A` is symmetric and `b = c`, BiLQ is equivalent to SYMMLQ.

An option gives the possibility of transferring to the BiCG point,
when it exists. The transfer is based on the residual norm.

#### Reference

* A. Montoison and D. Orban, [*BiLQ: An Iterative Method for Nonsymmetric Linear Systems with a Quasi-Minimum Error Property*](https://doi.org/10.1137/19M1290991), SIAM Journal on Matrix Analysis and Applications, 41(3), pp. 1145--1166, 2020.
"""
function bilq(A, b :: AbstractVector{T}; kwargs...) where T <: AbstractFloat
  solver = BilqSolver(A, b)
  bilq!(solver, A, b; kwargs...)
  return (solver.x, solver.stats)
end

"""
    solver = bilq!(solver::BilqSolver, args...; kwargs...)

where `args` and `kwargs` are arguments and keyword arguments of [`bilq`](@ref).

See [`BilqSolver`](@ref) for more details about the `solver`.
"""
function bilq!(solver :: BilqSolver{T,S}, A, b :: AbstractVector{T}; c :: AbstractVector{T}=b,
               atol :: T=√eps(T), rtol :: T=√eps(T), transfer_to_bicg :: Bool=true,
               itmax :: Int=0, verbose :: Int=0, history :: Bool=false) where {T <: AbstractFloat, S <: DenseVector{T}}

  n, m = size(A)
  m == n || error("System must be square")
  length(b) == m || error("Inconsistent problem size")
  (verbose > 0) && @printf("BILQ: system of size %d\n", n)

  # Check type consistency
  eltype(A) == T || error("eltype(A) ≠ $T")
  ktypeof(b) == S || error("ktypeof(b) ≠ $S")
  ktypeof(c) == S || error("ktypeof(c) ≠ $S")

  # Compute the adjoint of A
  Aᵀ = A'

  # Set up workspace.
  uₖ₋₁, uₖ, q, vₖ₋₁, vₖ = solver.uₖ₋₁, solver.uₖ, solver.q, solver.vₖ₋₁, solver.vₖ
  p, x, d̅, stats = solver.p, solver.x, solver.d̅, solver.stats
  rNorms = stats.residuals
  reset!(stats)

  # Initial solution x₀ and residual norm ‖r₀‖.
  x .= zero(T)
  bNorm = @knrm2(n, b)  # ‖r₀‖

  history && push!(rNorms, bNorm)
  if bNorm == 0
    stats.solved = true
    stats.inconsistent = false
    stats.status = "x = 0 is a zero-residual solution"
    return solver
  end

  iter = 0
  itmax == 0 && (itmax = 2*n)

  ε = atol + rtol * bNorm
  (verbose > 0) && @printf("%5s  %7s\n", "k", "‖rₖ‖")
  display(iter, verbose) && @printf("%5d  %7.1e\n", iter, bNorm)

  # Initialize the Lanczos biorthogonalization process.
  bᵗc = @kdot(n, b, c)  # ⟨b,c⟩
  if bᵗc == 0
    stats.solved = false
    stats.inconsistent = false
    stats.status = "Breakdown bᵀc = 0"
    return solver
  end

  βₖ = √(abs(bᵗc))           # β₁γ₁ = bᵀc
  γₖ = bᵗc / βₖ              # β₁γ₁ = bᵀc
  vₖ₋₁ .= zero(T)            # v₀ = 0
  uₖ₋₁ .= zero(T)            # u₀ = 0
  vₖ .= b ./ βₖ              # v₁ = b / β₁
  uₖ .= c ./ γₖ              # u₁ = c / γ₁
  cₖ₋₁ = cₖ = -one(T)        # Givens cosines used for the LQ factorization of Tₖ
  sₖ₋₁ = sₖ = zero(T)        # Givens sines used for the LQ factorization of Tₖ
  d̅ .= zero(T)               # Last column of D̅ₖ = Vₖ(Qₖ)ᵀ
  ζₖ₋₁ = ζbarₖ = zero(T)     # ζₖ₋₁ and ζbarₖ are the last components of z̅ₖ = (L̅ₖ)⁻¹β₁e₁
  ζₖ₋₂ = ηₖ = zero(T)        # ζₖ₋₂ and ηₖ are used to update ζₖ₋₁ and ζbarₖ
  δbarₖ₋₁ = δbarₖ = zero(T)  # Coefficients of Lₖ₋₁ and L̅ₖ modified over the course of two iterations
  norm_vₖ = bNorm / βₖ       # ‖vₖ‖ is used for residual norm estimates

  # Stopping criterion.
  solved_lq = bNorm ≤ ε
  solved_cg = false
  breakdown = false
  tired     = iter ≥ itmax
  status    = "unknown"

  while !(solved_lq || solved_cg || tired || breakdown)
    # Update iteration index.
    iter = iter + 1

    # Continue the Lanczos biorthogonalization process.
    # AVₖ  = VₖTₖ    + βₖ₊₁vₖ₊₁(eₖ)ᵀ = Vₖ₊₁Tₖ₊₁.ₖ
    # AᵀUₖ = Uₖ(Tₖ)ᵀ + γₖ₊₁uₖ₊₁(eₖ)ᵀ = Uₖ₊₁(Tₖ.ₖ₊₁)ᵀ

    mul!(q, A , vₖ)  # Forms vₖ₊₁ : q ← Avₖ
    mul!(p, Aᵀ, uₖ)  # Forms uₖ₊₁ : p ← Aᵀuₖ

    @kaxpy!(n, -γₖ, vₖ₋₁, q)  # q ← q - γₖ * vₖ₋₁
    @kaxpy!(n, -βₖ, uₖ₋₁, p)  # p ← p - βₖ * uₖ₋₁

    αₖ = @kdot(n, q, uₖ)      # αₖ = qᵀuₖ

    @kaxpy!(n, -αₖ, vₖ, q)    # q ← q - αₖ * vₖ
    @kaxpy!(n, -αₖ, uₖ, p)    # p ← p - αₖ * uₖ

    qᵗp = @kdot(n, p, q)      # qᵗp  = ⟨q,p⟩
    βₖ₊₁ = √(abs(qᵗp))        # βₖ₊₁ = √(|qᵗp|)
    γₖ₊₁ = qᵗp / βₖ₊₁         # γₖ₊₁ = qᵗp / βₖ₊₁

    # Update the LQ factorization of Tₖ = L̅ₖQₖ.
    # [ α₁ γ₂ 0  •  •  •  0 ]   [ δ₁   0    •   •   •    •    0   ]
    # [ β₂ α₂ γ₃ •        • ]   [ λ₁   δ₂   •                 •   ]
    # [ 0  •  •  •  •     • ]   [ ϵ₁   λ₂   δ₃  •             •   ]
    # [ •  •  •  •  •  •  • ] = [ 0    •    •   •   •         •   ] Qₖ
    # [ •     •  •  •  •  0 ]   [ •    •    •   •   •    •    •   ]
    # [ •        •  •  •  γₖ]   [ •         •   •   •    •    0   ]
    # [ 0  •  •  •  0  βₖ αₖ]   [ •    •    •   0  ϵₖ₋₂ λₖ₋₁ δbarₖ]

    if iter == 1
      δbarₖ = αₖ
    elseif iter == 2
      # [δbar₁ γ₂] [c₂  s₂] = [δ₁   0  ]
      # [ β₂   α₂] [s₂ -c₂]   [λ₁ δbar₂]
      (cₖ, sₖ, δₖ₋₁) = sym_givens(δbarₖ₋₁, γₖ)
      λₖ₋₁  = cₖ * βₖ + sₖ * αₖ
      δbarₖ = sₖ * βₖ - cₖ * αₖ
    else
      # [0  βₖ  αₖ] [cₖ₋₁   sₖ₋₁   0] = [sₖ₋₁βₖ  -cₖ₋₁βₖ  αₖ]
      #             [sₖ₋₁  -cₖ₋₁   0]
      #             [ 0      0     1]
      #
      # [ λₖ₋₂   δbarₖ₋₁  γₖ] [1   0   0 ] = [λₖ₋₂  δₖ₋₁    0  ]
      # [sₖ₋₁βₖ  -cₖ₋₁βₖ  αₖ] [0   cₖ  sₖ]   [ϵₖ₋₂  λₖ₋₁  δbarₖ]
      #                       [0   sₖ -cₖ]
      (cₖ, sₖ, δₖ₋₁) = sym_givens(δbarₖ₋₁, γₖ)
      ϵₖ₋₂  =  sₖ₋₁ * βₖ
      λₖ₋₁  = -cₖ₋₁ * cₖ * βₖ + sₖ * αₖ
      δbarₖ = -cₖ₋₁ * sₖ * βₖ - cₖ * αₖ
    end

    # Compute ζₖ₋₁ and ζbarₖ, last components of the solution of Lₖz̅ₖ = β₁e₁
    # [δbar₁] [ζbar₁] = [β₁]
    if iter == 1
      ηₖ = βₖ
    end
    # [δ₁    0  ] [  ζ₁ ] = [β₁]
    # [λ₁  δbar₂] [ζbar₂]   [0 ]
    if iter == 2
      ηₖ₋₁ = ηₖ
      ζₖ₋₁ = ηₖ₋₁ / δₖ₋₁
      ηₖ   = -λₖ₋₁ * ζₖ₋₁
    end
    # [λₖ₋₂  δₖ₋₁    0  ] [ζₖ₋₂ ] = [0]
    # [ϵₖ₋₂  λₖ₋₁  δbarₖ] [ζₖ₋₁ ]   [0]
    #                     [ζbarₖ]
    if iter ≥ 3
      ζₖ₋₂ = ζₖ₋₁
      ηₖ₋₁ = ηₖ
      ζₖ₋₁ = ηₖ₋₁ / δₖ₋₁
      ηₖ   = -ϵₖ₋₂ * ζₖ₋₂ - λₖ₋₁ * ζₖ₋₁
    end

    # Relations for the directions dₖ₋₁ and d̅ₖ, the last two columns of D̅ₖ = Vₖ(Qₖ)ᵀ.
    # [d̅ₖ₋₁ vₖ] [cₖ  sₖ] = [dₖ₋₁ d̅ₖ] ⟷ dₖ₋₁ = cₖ * d̅ₖ₋₁ + sₖ * vₖ
    #           [sₖ -cₖ]             ⟷ d̅ₖ   = sₖ * d̅ₖ₋₁ - cₖ * vₖ
    if iter ≥ 2
      # Compute solution xₖ.
      # (xᴸ)ₖ₋₁ ← (xᴸ)ₖ₋₂ + ζₖ₋₁ * dₖ₋₁
      @kaxpy!(n, ζₖ₋₁ * cₖ,  d̅, x)
      @kaxpy!(n, ζₖ₋₁ * sₖ, vₖ, x)
    end

    # Compute d̅ₖ.
    if iter == 1
      # d̅₁ = v₁
      @. d̅ = vₖ
    else
      # d̅ₖ = sₖ * d̅ₖ₋₁ - cₖ * vₖ
      @kaxpby!(n, -cₖ, vₖ, sₖ, d̅)
    end

    # Compute vₖ₊₁ and uₖ₊₁.
    @. vₖ₋₁ = vₖ # vₖ₋₁ ← vₖ
    @. uₖ₋₁ = uₖ # uₖ₋₁ ← uₖ

    if qᵗp ≠ 0
      @. vₖ = q / βₖ₊₁ # βₖ₊₁vₖ₊₁ = q
      @. uₖ = p / γₖ₊₁ # γₖ₊₁uₖ₊₁ = p
    end

    # Compute ⟨vₖ,vₖ₊₁⟩ and ‖vₖ₊₁‖
    vₖᵀvₖ₊₁ = @kdot(n, vₖ₋₁, vₖ)
    norm_vₖ₊₁ = @knrm2(n, vₖ)

    # Compute BiLQ residual norm
    # ‖rₖ‖ = √((μₖ)²‖vₖ‖² + (ωₖ)²‖vₖ₊₁‖² + 2μₖωₖ⟨vₖ,vₖ₊₁⟩)
    if iter == 1
      rNorm_lq = bNorm
    else
      μₖ = βₖ * (sₖ₋₁ * ζₖ₋₂ - cₖ₋₁ * cₖ * ζₖ₋₁) + αₖ * sₖ * ζₖ₋₁
      ωₖ = βₖ₊₁ * sₖ * ζₖ₋₁
      rNorm_lq = sqrt(μₖ^2 * norm_vₖ^2 + ωₖ^2 * norm_vₖ₊₁^2 + 2 * μₖ * ωₖ * vₖᵀvₖ₊₁)
    end
    history && push!(rNorms, rNorm_lq)

    # Compute BiCG residual norm
    # ‖rₖ‖ = |ρₖ| * ‖vₖ₊₁‖
    if transfer_to_bicg && (δbarₖ ≠ 0)
      ζbarₖ = ηₖ / δbarₖ
      ρₖ = βₖ₊₁ * (sₖ * ζₖ₋₁ - cₖ * ζbarₖ)
      rNorm_cg = abs(ρₖ) * norm_vₖ₊₁
    end

    # Update sₖ₋₁, cₖ₋₁, γₖ, βₖ, δbarₖ₋₁ and norm_vₖ.
    sₖ₋₁    = sₖ
    cₖ₋₁    = cₖ
    γₖ      = γₖ₊₁
    βₖ      = βₖ₊₁
    δbarₖ₋₁ = δbarₖ
    norm_vₖ = norm_vₖ₊₁

    # Update stopping criterion.
    solved_lq = rNorm_lq ≤ ε
    solved_cg = transfer_to_bicg && (δbarₖ ≠ 0) && (rNorm_cg ≤ ε)
    tired = iter ≥ itmax
    breakdown = !solved_lq && !solved_cg && (qᵗp == 0)
    display(iter, verbose) && @printf("%5d  %7.1e\n", iter, rNorm_lq)
  end
  (verbose > 0) && @printf("\n")

  # Compute BICG point
  # (xᶜ)ₖ ← (xᴸ)ₖ₋₁ + ζbarₖ * d̅ₖ
  if solved_cg
    @kaxpy!(n, ζbarₖ, d̅, x)
  end

  tired     && (status = "maximum number of iterations exceeded")
  breakdown && (status = "Breakdown ⟨uₖ₊₁,vₖ₊₁⟩ = 0")
  solved_lq && (status = "solution xᴸ good enough given atol and rtol")
  solved_cg && (status = "solution xᶜ good enough given atol and rtol")

  # Update stats
  stats.solved = solved_lq || solved_cg
  stats.inconsistent = false
  stats.status = status
  return solver
end
