module Core

using MacroTools, Libtask, ForwardDiff
using ..Utilities, Reexport
using Tracker
using ..Turing: Turing, Model, runmodel!,
    AbstractSampler, Sampler, SampleFromPrior

include("VarReplay.jl")
@reexport using .VarReplay

include("compiler.jl")
include("container.jl")
include("ad.jl")
include("ad_ext.jl")

export  @model,
        @VarName,
        generate_observe,
        translate_tilde!,
        get_vars,
        get_data,
        get_default_values,
        ParticleContainer,
        Particle,
        Trace,
        fork,
        forkr,
        current_trace,
        weights,
        effectiveSampleSize,
        increase_logweight,
        inrease_logevidence,
        resample!,
        getsample, 
        ADBackend,
        setadbackend, 
        setadsafe, 
        ForwardDiffAD, 
        FluxTrackerAD,
        value,
        gradient_logp,
        CHUNKSIZE, 
        ADBACKEND,
        setchunksize,
        verifygrad,
        gradient_logp_forward,
        gradient_logp_reverse,
        mvnormlogpdf

end # module
