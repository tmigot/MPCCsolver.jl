gc()

#Tests des packages
include("../ALAS/include.jl")

using MPCCmod
using OutputRelaxationmod

using CUTEst
using NLPModels

problems_unconstrained = CUTEst.select(contype="unc")
problems_linconstrained = CUTEst.select(contype="linear")
problems_boundconstrained = CUTEst.select(contype="bounds")
problems_quadconstrained = CUTEst.select(contype="quadratic")
problems_genconstrained = CUTEst.select(contype="general")

nlp = CUTEstModel(problems_quadconstrained[1])
print(nlp)

#déclare le mpcc :
@printf("Create an MPCC \n")
@time exemple_nlp=MPCCmod.MPCC(nlp)

@printf("%i %i %i %i %i %i %i %i \n",nlp.counters.neval_obj,
        nlp.counters.neval_cons,nlp.counters.neval_grad,
        nlp.counters.neval_hess,exemple_nlp.G.counters.neval_cons,
        exemple_nlp.G.counters.neval_jac,exemple_nlp.H.counters.neval_cons
        ,exemple_nlp.H.counters.neval_jac)

@printf("Butterfly method:\n")
#résolution avec ALAS Butterfly
@time xb,fb,orb,nb_eval = MPCCsolve.solve(exemple_nlp)
@show nb_eval

finalize(nlp)