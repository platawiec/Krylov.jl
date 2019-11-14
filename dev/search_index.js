var documenterSearchIndex = {"docs":
[{"location":"api/#Types-1","page":"API","title":"Types","text":"","category":"section"},{"location":"api/#","page":"API","title":"API","text":"Krylov.KrylovStats\nKrylov.SimpleStats\nKrylov.LanczosStats\nKrylov.SymmlqStats","category":"page"},{"location":"api/#Krylov.KrylovStats","page":"API","title":"Krylov.KrylovStats","text":"Abstract type for statistics returned by a solver\n\n\n\n\n\n","category":"type"},{"location":"api/#Krylov.SimpleStats","page":"API","title":"Krylov.SimpleStats","text":"Type for statistics returned by non-Lanczos solvers\n\n\n\n\n\n","category":"type"},{"location":"api/#Krylov.LanczosStats","page":"API","title":"Krylov.LanczosStats","text":"Type for statistics returned by Lanczos solvers\n\n\n\n\n\n","category":"type"},{"location":"api/#Krylov.SymmlqStats","page":"API","title":"Krylov.SymmlqStats","text":"Type for statistics returned by SYMMLQ\n\n\n\n\n\n","category":"type"},{"location":"api/#Utilities-1","page":"API","title":"Utilities","text":"","category":"section"},{"location":"api/#","page":"API","title":"API","text":"Krylov.roots_quadratic\nKrylov.sym_givens\nKrylov.to_boundary\nKrylov.vec2str","category":"page"},{"location":"api/#Krylov.roots_quadratic","page":"API","title":"Krylov.roots_quadratic","text":"Find the real roots of the quadratic\n\nq(x) = q₂ x² + q₁ x + q₀,\n\nwhere q₂, q₁ and q₀ are real. Care is taken to avoid numerical cancellation. Optionally, nitref steps of iterative refinement may be performed to improve accuracy. By default, nitref=1.\n\n\n\n\n\n","category":"function"},{"location":"api/#Krylov.sym_givens","page":"API","title":"Krylov.sym_givens","text":"Numerically stable symmetric Givens reflection. Given a and b, return (c, s, ρ) such that\n\n[ c  s ] [ a ] = [ ρ ]\n[ s -c ] [ b ] = [ 0 ].\n\n\n\n\n\n","category":"function"},{"location":"api/#Krylov.to_boundary","page":"API","title":"Krylov.to_boundary","text":"Given a trust-region radius radius, a vector x lying inside the trust-region and a direction d, return σ1 and σ2 such that\n\n‖x + σi d‖ = radius, i = 1, 2\n\nin the Euclidean norm. If known, ‖x‖² may be supplied in xNorm2.\n\nIf flip is set to true, σ1 and σ2 are computed such that\n\n‖x - σi d‖ = radius, i = 1, 2.\n\n\n\n\n\n","category":"function"},{"location":"api/#Krylov.vec2str","page":"API","title":"Krylov.vec2str","text":"Display an array in the form\n\n[ -3.0e-01 -5.1e-01  1.9e-01 ... -2.3e-01 -4.4e-01  2.4e-01 ]\n\nwith (ndisp - 1)/2 elements on each side.\n\n\n\n\n\n","category":"function"},{"location":"solvers/#","page":"Solvers","title":"Solvers","text":"All methods require that A is an AbstractLinearOperator. But a variant allows you to give A as an AbstractMatrix. Thereafter A is automatically wrapped in a LinearOperator.","category":"page"},{"location":"solvers/#","page":"Solvers","title":"Solvers","text":"Detailed examples may be found here.","category":"page"},{"location":"solvers/#Krylov-methods-1","page":"Solvers","title":"Krylov methods","text":"","category":"section"},{"location":"solvers/#","page":"Solvers","title":"Solvers","text":"cg\ncr\nsymmlq\ncg_lanczos\ncg_lanczos_shift_seq\nminres\nminres_qlp\ndiom\ndqgmres\nusymqr\nbilq\ncgs\ncgls\ncrls\ncgne\ncrmr\nlslq\nlsqr\nlsmr\ncraig\ncraigmr","category":"page"},{"location":"solvers/#Krylov.cg","page":"Solvers","title":"Krylov.cg","text":"The conjugate gradient method to solve the symmetric linear system Ax=b.\n\nThe method does not abort if A is not definite.\n\nA preconditioner M may be provided in the form of a linear operator and is assumed to be symmetric and positive definite.\n\n\n\n\n\n","category":"function"},{"location":"solvers/#Krylov.cr","page":"Solvers","title":"Krylov.cr","text":"A truncated version of Stiefel’s Conjugate Residual method to solve the symmetric linear system Ax=b. The matrix A must be positive semi-definite.\n\nA preconditioner M may be provided in the form of a linear operator and is assumed to be symmetric and positive definite. In a linesearch context, 'linesearch' must be set to 'true'.\n\n\n\n\n\n","category":"function"},{"location":"solvers/#Krylov.symmlq","page":"Solvers","title":"Krylov.symmlq","text":"Solve the shifted linear system\n\n(A + λ I) x = b\n\nusing the SYMMLQ method, where λ is a shift parameter, and A is square and symmetric.\n\nSYMMLQ produces monotonic errors ‖x*-x‖₂.\n\nA preconditioner M may be provided in the form of a linear operator and is assumed to be symmetric and positive definite.\n\n\n\n\n\n","category":"function"},{"location":"solvers/#Krylov.cg_lanczos","page":"Solvers","title":"Krylov.cg_lanczos","text":"The Lanczos version of the conjugate gradient method to solve the symmetric linear system\n\nAx = b\n\nThe method does not abort if A is not definite.\n\nA preconditioner M may be provided in the form of a linear operator and is assumed to be symmetric and positive definite.\n\n\n\n\n\n","category":"function"},{"location":"solvers/#Krylov.cg_lanczos_shift_seq","page":"Solvers","title":"Krylov.cg_lanczos_shift_seq","text":"The Lanczos version of the conjugate gradient method to solve a family of shifted systems\n\n(A + αI) x = b  (α = α₁, ..., αₙ)\n\nThe method does not abort if A + αI is not definite.\n\nA preconditioner M may be provided in the form of a linear operator and is assumed to be symmetric and positive definite.\n\n\n\n\n\n","category":"function"},{"location":"solvers/#Krylov.minres","page":"Solvers","title":"Krylov.minres","text":"Solve the shifted linear least-squares problem\n\nminimize ‖b - (A + λ I)x‖₂²\n\nor the shifted linear system\n\n(A + λ I) x = b\n\nusing the MINRES method, where λ ≥ 0 is a shift parameter, where A is square and symmetric.\n\nMINRES is formally equivalent to applying CR to Ax=b when A is positive definite, but is typically more stable and also applies to the case where A is indefinite.\n\nMINRES produces monotonic residuals ‖r‖₂ and optimality residuals ‖Aᵀr‖₂.\n\nA preconditioner M may be provided in the form of a linear operator and is assumed to be symmetric and positive definite.\n\n\n\n\n\n","category":"function"},{"location":"solvers/#Krylov.minres_qlp","page":"Solvers","title":"Krylov.minres_qlp","text":"MINRES-QLP is the only method based on the Lanczos process that returns the minimum-norm solution on singular inconsistent systems (A + λI)x = b, where λ is a shift parameter. It is significantly more complex but can be more reliable than MINRES when A is ill-conditioned.\n\nThis version of MINRES-QLP works in any floating-point data type.\n\n\n\n\n\n","category":"function"},{"location":"solvers/#Krylov.diom","page":"Solvers","title":"Krylov.diom","text":"Solve the consistent linear system Ax = b using direct incomplete orthogonalization method.\n\nDIOM is similar to CG with partial reorthogonalization.\n\nAn advantage of DIOM is that nonsymmetric or symmetric indefinite or both nonsymmetric and indefinite systems of linear equations can be handled by this single algorithm.\n\nThis implementation allows a left preconditioner M and a right preconditioner N.\n\nLeft  preconditioning : M⁻¹Ax = M⁻¹b\nRight preconditioning : AN⁻¹u = b with x = N⁻¹u\nSplit preconditioning : M⁻¹AN⁻¹u = M⁻¹b with x = N⁻¹u\n\n\n\n\n\n","category":"function"},{"location":"solvers/#Krylov.dqgmres","page":"Solvers","title":"Krylov.dqgmres","text":"Solve the consistent linear system Ax = b using DQGMRES method.\n\nDQGMRES algorithm is based on the incomplete Arnoldi orthogonalization process and computes a sequence of approximate solutions with the quasi-minimal residual property.\n\nThis implementation allows a left preconditioner M and a right preconditioner N.\n\nLeft  preconditioning : M⁻¹Ax = M⁻¹b\nRight preconditioning : AN⁻¹u = b with x = N⁻¹u\nSplit preconditioning : M⁻¹AN⁻¹u = M⁻¹b with x = N⁻¹u\n\n\n\n\n\n","category":"function"},{"location":"solvers/#Krylov.usymqr","page":"Solvers","title":"Krylov.usymqr","text":"Solve the linear system Ax = b using the USYMQR method. USYMQR can also be applied to under-determined and over-determined problems.\n\nUSYMQR is based on a tridiagonalization process for unsymmetric matrices. It's considered as a generalization of MINRES.\n\nIt can also be applied to under-determined and over-determined problems.\n\nThis version of USYMQR works in any floating-point data type.\n\n\n\n\n\n","category":"function"},{"location":"solvers/#Krylov.bilq","page":"Solvers","title":"Krylov.bilq","text":"Solve the square linear system Ax = b using the BiLQ method.\n\nBiLQ is based on the Lanczos biorthogonalization process. When A is symmetric and b = c, BiLQ is equivalent to SYMMLQ.\n\nAn option gives the possibility of transferring to the BiCG point, when it exists. The transfer is based on the residual norm.\n\nThis version of BiLQ works in any floating-point data type.\n\n\n\n\n\n","category":"function"},{"location":"solvers/#Krylov.cgs","page":"Solvers","title":"Krylov.cgs","text":"Solve the consistent linear system Ax = b using conjugate gradient squared algorithm.\n\nFrom \"Iterative Methods for Sparse Linear Systems (Y. Saad)\" :\n\n«The method is based on a polynomial variant of the conjugate gradients algorithm. Although related to the so-called bi-conjugate gradients (BCG) algorithm, it does not involve adjoint matrix-vector multiplications, and the expected convergence rate is about twice that of the BCG algorithm.\n\nThe Conjugate Gradient Squared algorithm works quite well in many cases. However, one difficulty is that, since the polynomials are squared, rounding errors tend to be more damaging than in the standard BCG algorithm. In particular, very high variations of the residual vectors often cause the residual norms computed to become inaccurate.\n\nTFQMR and BICGSTAB were developed to remedy this difficulty.»\n\nThis implementation allows a right preconditioner M.\n\n\n\n\n\n","category":"function"},{"location":"solvers/#Krylov.cgls","page":"Solvers","title":"Krylov.cgls","text":"Solve the regularized linear least-squares problem\n\nminimize ‖b - Ax‖₂² + λ ‖x‖₂²\n\nusing the Conjugate Gradient (CG) method, where λ ≥ 0 is a regularization parameter. This method is equivalent to applying CG to the normal equations\n\n(AᵀA + λI) x = Aᵀb\n\nbut is more stable.\n\nCGLS produces monotonic residuals ‖r‖₂ but not optimality residuals ‖Aᵀr‖₂. It is formally equivalent to LSQR, though can be slightly less accurate, but simpler to implement.\n\n\n\n\n\n","category":"function"},{"location":"solvers/#Krylov.crls","page":"Solvers","title":"Krylov.crls","text":"Solve the linear least-squares problem\n\nminimize ‖b - Ax‖₂² + λ ‖x‖₂²\n\nusing the Conjugate Residuals (CR) method. This method is equivalent to applying MINRES to the normal equations\n\n(AᵀA + λI) x = Aᵀb.\n\nThis implementation recurs the residual r := b - Ax.\n\nCRLS produces monotonic residuals ‖r‖₂ and optimality residuals ‖Aᵀr‖₂. It is formally equivalent to LSMR, though can be substantially less accurate, but simpler to implement.\n\n\n\n\n\n","category":"function"},{"location":"solvers/#Krylov.cgne","page":"Solvers","title":"Krylov.cgne","text":"Solve the consistent linear system\n\nAx + √λs = b\n\nusing the Conjugate Gradient (CG) method, where λ ≥ 0 is a regularization parameter. This method is equivalent to applying CG to the normal equations of the second kind\n\n(AAᵀ + λI) y = b\n\nbut is more stable. When λ = 0, this method solves the minimum-norm problem\n\nmin ‖x‖₂  s.t. Ax = b.\n\nWhen λ > 0, it solves the problem\n\nmin ‖(x,s)‖₂  s.t. Ax + √λs = b.\n\nCGNE produces monotonic errors ‖x-x*‖₂ but not residuals ‖r‖₂. It is formally equivalent to CRAIG, though can be slightly less accurate, but simpler to implement. Only the x-part of the solution is returned.\n\nA preconditioner M may be provided in the form of a linear operator.\n\n\n\n\n\n","category":"function"},{"location":"solvers/#Krylov.crmr","page":"Solvers","title":"Krylov.crmr","text":"Solve the consistent linear system\n\nAx + √λs = b\n\nusing the Conjugate Residual (CR) method, where λ ≥ 0 is a regularization parameter. This method is equivalent to applying CR to the normal equations of the second kind\n\n(AAᵀ + λI) y = b\n\nbut is more stable. When λ = 0, this method solves the minimum-norm problem\n\nmin ‖x‖₂  s.t.  x ∈ argmin ‖Ax - b‖₂.\n\nWhen λ > 0, this method solves the problem\n\nmin ‖(x,s)‖₂  s.t. Ax + √λs = b.\n\nCGMR produces monotonic residuals ‖r‖₂. It is formally equivalent to CRAIG-MR, though can be slightly less accurate, but simpler to implement. Only the x-part of the solution is returned.\n\nA preconditioner M may be provided in the form of a linear operator.\n\n\n\n\n\n","category":"function"},{"location":"solvers/#Krylov.lslq","page":"Solvers","title":"Krylov.lslq","text":"lslq(A, b, λ=0.0)\n\nSolve the regularized linear least-squares problem\n\nminimize ‖b - Ax‖₂² + λ² ‖x‖₂²\n\nusing the LSLQ method, where λ ≥ 0 is a regularization parameter. LSLQ is formally equivalent to applying SYMMLQ to the normal equations\n\n(AᵀA + λ² I) x = Aᵀb\n\nbut is more stable.\n\nMain features\n\nthe solution estimate is updated along orthogonal directions\nthe norm of the solution estimate ‖xᴸₖ‖₂ is increasing\nthe error ‖eₖ‖₂ := ‖xᴸₖ - x*‖₂ is decreasing\nit is possible to transition cheaply from the LSLQ iterate to the LSQR iterate if there is an advantage (there always is in terms of error)\nif A is rank deficient, identify the minimum least-squares solution\n\nInput arguments\n\nA::AbstractLinearOperator\nb::Vector{Float64}\n\nOptional arguments\n\nM::AbstractLinearOperator=opEye(size(A,1)): a symmetric and positive definite dual preconditioner\nN::AbstractLinearOperator=opEye(size(A,2)): a symmetric and positive definite primal preconditioner\nsqd::Bool=false indicates whether or not we are solving a symmetric and quasi-definite augmented system If sqd = true, we solve the symmetric and quasi-definite system\n[ E   Aᵀ ] [ r ]   [ b ]\n[ A  -F  ] [ x ] = [ 0 ],\nwhere E = M⁻¹  and F = N⁻¹.\nIf sqd = false, we solve the symmetric and indefinite system\n[ E   Aᵀ ] [ r ]   [ b ]\n[ A   0  ] [ x ] = [ 0 ].\nIn this case, N can still be specified and indicates the norm in which x and the forward error should be measured.\nλ::Float64=0.0 is a regularization parameter (see the problem statement above)\nσ::Float64=0.0 is an underestimate of the smallest nonzero singular value of A–-setting σ too large will result in an error in the course of the iterations\natol::Float64=1.0e-8 is a stopping tolerance based on the residual\nbtol::Float64=1.0e-8 is a stopping tolerance used to detect zero-residual problems\netol::Float64=1.0e-8 is a stopping tolerance based on the lower bound on the error\nwindow::Int=5 is the number of iterations used to accumulate a lower bound on the error\nutol::Float64=1.0e-8 is a stopping tolerance based on the upper bound on the error\nitmax::Int=0 is the maximum number of iterations (0 means no imposed limit)\nconlim::Float64=1.0e+8 is the limit on the estimated condition number of A beyond which the solution will be abandoned\nverbose::Bool=false determines verbosity.\n\nReturn values\n\nlslq() returns the tuple (x_lq, x_cg, err_lbnds, err_ubnds_lq, err_ubnds_cg, stats) where\n\nx_lq::Vector{Float64} is the LQ solution estimate\nx_cg::Vector{Float64} is the CG solution estimate (i.e., the LSQR point)\nerr_lbnds::Vector{Float64} is a vector of lower bounds on the LQ error–-the vector is empty if window is set to zero\nerr_ubnds_lq::Vector{Float64} is a vector of upper bounds on the LQ error–-the vector is empty if σ == 0 is left at zero\nerr_ubnds_cg::Vector{Float64} is a vector of upper bounds on the CG error–-the vector is empty if σ == 0 is left at zero\nstats::SimpleStats collects other statistics on the run.\n\nStopping conditions\n\nThe iterations stop as soon as one of the following conditions holds true:\n\nthe optimality residual is sufficiently small (stats.status = \"found approximate minimum least-squares solution\") in the sense that either\n‖Aᵀr‖ / (‖A‖ ‖r‖) ≤ atol, or\n1 + ‖Aᵀr‖ / (‖A‖ ‖r‖) ≤ 1\nan approximate zero-residual solution has been found (stats.status = \"found approximate zero-residual solution\") in the sense that either\n‖r‖ / ‖b‖ ≤ btol + atol ‖A‖ * ‖xᴸ‖ / ‖b‖, or\n1 + ‖r‖ / ‖b‖ ≤ 1\nthe estimated condition number of A is too large in the sense that either\n1/cond(A) ≤ 1/conlim (stats.status = \"condition number exceeds tolerance\"), or\n1 + 1/cond(A) ≤ 1 (stats.status = \"condition number seems too large for this machine\")\nthe lower bound on the LQ forward error is less than etol * ‖xᴸ‖\nthe upper bound on the CG forward error is less than utol * ‖xᶜ‖\n\nReferences\n\nR. Estrin, D. Orban and M. A. Saunders, Estimates of the 2-Norm Forward Error for SYMMLQ and CG, Cahier du GERAD G-2016-70, GERAD, Montreal, 2016. DOI http://dx.doi.org/10.13140/RG.2.2.19581.77288.\nR. Estrin, D. Orban and M. A. Saunders, LSLQ: An Iterative Method for Linear Least-Squares with an Error Minimization Property, Cahier du GERAD G-2017-xx, GERAD, Montreal, 2017.\n\n\n\n\n\n","category":"function"},{"location":"solvers/#Krylov.lsqr","page":"Solvers","title":"Krylov.lsqr","text":"Solve the regularized linear least-squares problem\n\nminimize ‖b - Ax‖₂² + λ² ‖x‖₂²\n\nusing the LSQR method, where λ ≥ 0 is a regularization parameter. LSQR is formally equivalent to applying CG to the normal equations\n\n(AᵀA + λ² I) x = Aᵀb\n\n(and therefore to CGLS) but is more stable.\n\nLSQR produces monotonic residuals ‖r‖₂ but not optimality residuals ‖Aᵀr‖₂. It is formally equivalent to CGLS, though can be slightly more accurate.\n\nPreconditioners M and N may be provided in the form of linear operators and are assumed to be symmetric and positive definite. If sqd is set to true, we solve the symmetric and quasi-definite system\n\n[ E   Aᵀ ] [ r ]   [ b ]\n[ A  -F  ] [ x ] = [ 0 ],\n\nwhere E = M⁻¹  and F = N⁻¹.\n\nIf sqd is set to false (the default), we solve the symmetric and indefinite system\n\n[ E   Aᵀ ] [ r ]   [ b ]\n[ A   0  ] [ x ] = [ 0 ].\n\nIn this case, N can still be specified and indicates the norm in which x should be measured.\n\n\n\n\n\n","category":"function"},{"location":"solvers/#Krylov.lsmr","page":"Solvers","title":"Krylov.lsmr","text":"Solve the regularized linear least-squares problem\n\nminimize ‖b - Ax‖₂² + λ² ‖x‖₂²\n\nusing the LSMR method, where λ ≥ 0 is a regularization parameter. LSQR is formally equivalent to applying MINRES to the normal equations\n\n(AᵀA + λ² I) x = Aᵀb\n\n(and therefore to CRLS) but is more stable.\n\nLSMR produces monotonic residuals ‖r‖₂ and optimality residuals ‖Aᵀr‖₂. It is formally equivalent to CRLS, though can be substantially more accurate.\n\nPreconditioners M and N may be provided in the form of linear operators and are assumed to be symmetric and positive definite. If sqd is set to true, we solve the symmetric and quasi-definite system\n\n[ E   Aᵀ ] [ r ]   [ b ]\n[ A  -F  ] [ x ] = [ 0 ],\n\nwhere E = M⁻¹  and F = N⁻¹.\n\nIf sqd is set to false (the default), we solve the symmetric and indefinite system\n\n[ E   Aᵀ ] [ r ]   [ b ]\n[ A   0  ] [ x ] = [ 0 ].\n\nIn this case, N can still be specified and indicates the norm in which x should be measured.\n\n\n\n\n\n","category":"function"},{"location":"solvers/#Krylov.craig","page":"Solvers","title":"Krylov.craig","text":"Find the least-norm solution of the consistent linear system\n\nAx + √λs = b\n\nusing the Golub-Kahan implementation of Craig's method, where λ ≥ 0 is a regularization parameter. This method is equivalent to CGNE but is more stable.\n\nFor a system in the form Ax = b, Craig's method is equivalent to applying CG to AAᵀy = b and recovering x = Aᵀy. Note that y are the Lagrange multipliers of the least-norm problem\n\nminimize ‖x‖  subject to Ax = b.\n\nPreconditioners M⁻¹ and N⁻¹ may be provided in the form of linear operators and are assumed to be symmetric and positive definite. Afterward CRAIG solves the symmetric and quasi-definite system\n\n[ -N   Aᵀ ] [ x ]   [ 0 ]\n[  A   M  ] [ y ] = [ b ],\n\nwhich is equivalent to applying CG to (M + AN⁻¹Aᵀ)y = b.\n\nIn this implementation, both the x and y-parts of the solution are returned.\n\n\n\n\n\n","category":"function"},{"location":"solvers/#Krylov.craigmr","page":"Solvers","title":"Krylov.craigmr","text":"Solve the consistent linear system\n\nAx + √λs = b\n\nusing the CRAIG-MR method, where λ ≥ 0 is a regularization parameter. This method is equivalent to applying the Conjugate Residuals method to the normal equations of the second kind\n\n(AAᵀ + λI) y = b\n\nbut is more stable. When λ = 0, this method solves the minimum-norm problem\n\nmin ‖x‖₂  s.t.  x ∈ argmin ‖Ax - b‖₂.\n\nWhen λ > 0, this method solves the problem\n\nmin ‖(x,s)‖₂  s.t. Ax + √λs = b.\n\nPreconditioners M⁻¹ and N⁻¹ may be provided in the form of linear operators and are assumed to be symmetric and positive definite. Afterward CRAIGMR solves the symmetric and quasi-definite system\n\n[ -N   Aᵀ ] [ x ]   [ 0 ]\n[  A   M  ] [ y ] = [ b ],\n\nwhich is equivalent to applying MINRES to (M + AN⁻¹Aᵀ)y = b.\n\nCRAIGMR produces monotonic residuals ‖r‖₂. It is formally equivalent to CRMR, though can be slightly more accurate, and intricate to implement. Both the x- and y-parts of the solution are returned.\n\n\n\n\n\n","category":"function"},{"location":"reference/#Reference-1","page":"Reference","title":"Reference","text":"","category":"section"},{"location":"reference/#","page":"Reference","title":"Reference","text":"","category":"page"},{"location":"#Home-1","page":"Home","title":"Krylov.jl documentation","text":"","category":"section"},{"location":"#","page":"Home","title":"Home","text":"This package implements iterative methods for the solution of linear systems of equations","category":"page"},{"location":"#","page":"Home","title":"Home","text":"  Ax = b","category":"page"},{"location":"#","page":"Home","title":"Home","text":"linear least-squares problems","category":"page"},{"location":"#","page":"Home","title":"Home","text":"  min b - Ax","category":"page"},{"location":"#","page":"Home","title":"Home","text":"and linear least-norm problems","category":"page"},{"location":"#","page":"Home","title":"Home","text":"  min x quad textsubject to  Ax = b","category":"page"},{"location":"#","page":"Home","title":"Home","text":"It is appropriate, in particular, in situations where such a problem must be solved but a factorization is not possible, either because:","category":"page"},{"location":"#","page":"Home","title":"Home","text":"the operator is not available explicitly,\nthe operator is dense, or\nfactors would consume an excessive amount of memory and/or disk space.","category":"page"},{"location":"#","page":"Home","title":"Home","text":"Iterative methods are particularly appropriate in either of the following situations:","category":"page"},{"location":"#","page":"Home","title":"Home","text":"the problem is sufficiently large that a factorization is not feasible or would be slower,\nan effective preconditioner is known in cases where the problem has unfavorable spectral structure,\nthe operator can be represented efficiently as a sparse matrix,\nthe operator is fast, i.e., can be applied with far better complexity than if it were materialized as a matrix. Often, fast operators would materialize as dense matrices.","category":"page"},{"location":"#Objective:-solve-Ax-\\approx-b-1","page":"Home","title":"Objective: solve Ax approx b","text":"","category":"section"},{"location":"#","page":"Home","title":"Home","text":"Given a linear operator A and a right-hand side b, solve Ax = b, which means:","category":"page"},{"location":"#","page":"Home","title":"Home","text":"when A has full column rank and b lies in the range space of A, find the unique x such that Ax = b; this situation occurs when\nA is square and nonsingular, or\nA is tall and has full column rank and b lies in the range of A,\nwhen A is column-rank deficient but b is in the range of A, find x with minimum norm such that Ax = b; this situation occurs when b is in the range of A and\nA is square but singular, or\nA is short and wide,\nwhen b is not in the range of A, regardless of the shape and rank of A, find x that minimizes the residual b - Ax. If there are infinitely many such x (because A is rank deficient), identify the one with minimum norm.","category":"page"},{"location":"#How-to-Install-1","page":"Home","title":"How to Install","text":"","category":"section"},{"location":"#","page":"Home","title":"Home","text":"Krylov can be installed and tested through the Julia package manager:","category":"page"},{"location":"#","page":"Home","title":"Home","text":"julia> Pkg.add(\"Krylov\")\njulia> Pkg.test(\"Krylov\")","category":"page"},{"location":"#Long-Term-Goals-1","page":"Home","title":"Long-Term Goals","text":"","category":"section"},{"location":"#","page":"Home","title":"Home","text":"provide implementations of certain of the most useful Krylov method for linear systems with special emphasis on methods for linear least-squares problems and saddle-point linear system (including symmetric quasi-definite systems)\nprovide state-of-the-art implementations alongside simple implementations of equivalent methods in exact artithmetic (e.g., LSQR vs. CGLS, MINRES vs. CR, LSMR vs. CRLS, etc.)\nprovide simple, consistent calling signatures and avoid over-typing\nensure those implementations are fast and stable.","category":"page"}]
}
