"""
Donne la violation de la réalisabilité dual (norme Infinie)
"""
function dual_feasibility_norm(mod      :: MPCC,
                               x        :: Vector,
                               l        :: Vector,
                               A        :: Any,
                               precmpcc :: Float64)

 return optimal = norm(dual_feasibility(mod, x, l, A), Inf) <= precmpcc
end

"""
Vérifie les signes de la M-stationarité (l entier)
"""
function sign_stationarity_check(mod      :: MPCC,
                                 x        :: Vector,
                                 l        :: Vector,
                                 precmpcc :: Float64)

  Il = find(z->norm(z-mod.mp.meta.lvar,Inf)<=precmpcc, x)
  Iu = find(z->norm(z-mod.mp.meta.uvar,Inf)<=precmpcc, x)

  IG = [];IH = [];Ig = [];Ih = [];

 if mod.mp.meta.ncon+mod.nb_comp > 0

  c = cons(mod.mp, x)
  Ig = find(z->norm(z-mod.mp.meta.lcon,Inf) <= precmpcc, c)
  Ih = find(z->norm(z-mod.mp.meta.ucon,Inf) <= precmpcc, c)

  if mod.nb_comp > 0

   IG = find(z->norm(z-mod.G.meta.lcon, Inf) <= precmpcc,NLPModels.cons(mod.G, x))
   IH = find(z->norm(z-mod.H.meta.lcon, Inf) <= precmpcc,NLPModels.cons(mod.H, x))

  end
 end

 #setdiff(∪(Il,Iu),∩(Il,Iu))
 l_pos = max.(l[1:2*n+2*mod.mp.meta.ncon], 0)

 I_biactif = ∩(IG,IH)
 lG = [2*n+2*mod.mp.meta.ncon+I_biactif]
 lH = [2*n+2*mod.mp.meta.ncon+mod.nb_comp+I_biactif]
 l_cc = min.(lG.*lH,max.(-lG,0)+max.(-lH,0))

 return norm([l_pos;l_cc],Inf)<=precmpcc
end

"""
Vérifie les signes de la M-stationarité (l actif)
"""
function sign_stationarity_check(mod::MPCC,
                                 x::Vector,
                                 l::Vector,
                                 Il::Array{Int64,1},Iu::Array{Int64,1},
                                 Ig::Array{Int64,1},Ih::Array{Int64,1},
                                 IG::Array{Int64,1},IH::Array{Int64,1},
                                 precmpcc::Float64)

 nl = length(Il)+length(Iu)+length(Ig)+length(Ih)
 nccG = length(IG)
 nccH = length(IH)

 l_pos = max.(l[1:nl],0)

 I_biactif = ∩(IG,IH)
 lG = l[I_biactif+nl]
 lH = l[nl+nccG+I_biactif]
 l_cc = min.(lG.*lH,max.(-lG,0)+max.(-lH,0))

 return norm([l_pos;l_cc],Inf) <= precmpcc
end

"""
For a given x, compute the multiplier and check the feasibility dual
"""
function stationary_check(mod      :: MPCC,
                          x        :: Vector,
                          precmpcc :: Float64)

 n = mod.n
 b = -grad(mod,x)

 if mod.mp.meta.ncon+mod.nb_comp ==0

  optimal = norm(b,Inf) <= precmpcc

 else

  A, Il, Iu, Ig, Ih, IG, IH = MPCCmod.jac_actif(mod, x, precmpcc)

  if !(true in isnan.(A) || true in isnan.(b))

   l = pinv(full(A))*b #pinv not defined for sparse matrix
   optimal = dual_feasibility_norm(mod, x, l, A, precmpcc)
   good_sign = sign_stationarity_check(mod, x, l, Il, Iu, Ig, Ih, IG, IH, precmpcc)

  else

   @printf("Evaluation error: NaN in the derivative")
   optimal=false

  end

 end

 return optimal && good_sign
end
