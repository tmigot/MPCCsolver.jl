"""
MPCCSolve(mod::MPCCmod.MPCC)
"""

module MPCCSolvemod

import MPCCmod.MPCC, MPCCmod.viol_comp

import SolveRelaxSubProblem.SolveSubproblemAlas

import ParamSetmod.ParamSet
import ParamMPCCmod.ParamMPCC
import AlgoSetmod.AlgoSet

import RMPCCmod.RMPCC,RMPCCmod.start!, RMPCCmod.update!
import StoppingMPCCmod.StoppingMPCC, StoppingMPCCmod.stop!
import StoppingMPCCmod.stop_start!, StoppingMPCCmod.final

import OutputRelaxationmod.OutputRelaxation,OutputRelaxationmod.UpdateOR
import OutputRelaxationmod.Print,OutputRelaxationmod.final!




type MPCCSolve

 mod        :: MPCC

 name_relax :: AbstractString

 xj         :: Vector #itéré courant

 algoset    :: AlgoSet
 paramset   :: ParamSet
 parammpcc  :: ParamMPCC

 rmpcc :: RMPCC
 smpcc :: StoppingMPCC

end

function MPCCSolve(mod        :: MPCC,
                   x          :: Vector;
                   name_relax :: String    = "KS",
                   algoset    :: AlgoSet   = AlgoSet(),
                   paramset   :: ParamSet  = ParamSet(mod.nbc),
                   parammpcc  :: ParamMPCC = ParamMPCC(mod.nbc))

 #solve_sub_pb=SolveRelaxSubProblem.SolveSubproblemIpOpt # ne marche pas (MPCCtoRelaxNLP problème)

 rmpcc = RMPCC(x)
 smpcc = StoppingMPCC(precmpcc = parammpcc.precmpcc,
                      paramin = parammpcc.paramin,
                      prec_oracle = parammpcc.prec_oracle)

 return MPCCSolve(mod,name_relax,x,algoset,paramset,parammpcc,rmpcc,smpcc)
end

"""
Accesseur : modifie le point initial
"""

function set_x(mod :: MPCCSolve,
               x0  :: Vector)

 mod.xj=x0

 return mod
end

###################################################################################
#
# MAIN FUNCTION: solve
#
###################################################################################

include("mpcc_solve.jl")



#end of module
end
