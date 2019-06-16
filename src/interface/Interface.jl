module Interface

import Distributions: sample, Sampleable
import Random: GLOBAL_RNG, AbstractRNG
import ..MCMCChains: Chains
import ProgressMeter

export AbstractSampler,
       AbstractTransition,
       sample_init!,
       sample_end!,
       sample,
       step!

"""
    AbstractSampler

The `AbstractSampler` type is intended to be inherited from when
implementing a custom sampler. Any persistent state information should be
saved in a subtype of `AbstractSampler`.

When defining a new sampler, you should also overload the function
`transition_type`, which tells the `sample` function what type of parameter
it should expect to receive.
"""
abstract type AbstractSampler end

"""
    AbstractTransition

The `AbstractTransition` type describes the results of a single step
of a given sampler. As an example, one implementation of an
`AbstractTransition` might include be a vector of parameters sampled from
a prior distribution.

Transition types should store a single draw from any sampler, since the
interface will sample `N` times, and store the results of each step in an
array of type `Array{Transition<:AbstractTransition, 1}`. If you were
using a sampler that returned a `NamedTuple` after each step, your
implementation might look like:

```
struct MyTransition <: AbstractTransition
    draw :: NamedTuple
end
```
"""
abstract type AbstractTransition end

"""
    AbstractCallback

An `AbstractCallback` types is a supertype to be inherited from if you want to use custom callback functionality. This is used to report sampling progress such as parameters calculated, remaining samples to run, or even plot graphs if you so choose.

In order to implement callback functionality, you need the following:

- A mutable struct that is a subtype of `AbstractCallback`
- An overload of the `init_callback` function
- An overload of the `callback` function
"""
abstract type AbstractCallback end

mutable struct DefaultCallback{
    ProgType<:ProgressMeter.AbstractProgress
} <: AbstractCallback
    p :: ProgType
end

DefaultCallback(N::Int) = DefaultCallback(ProgressMeter.Progress(N, 1))

function init_callback(
    rng::AbstractRNG,
    ℓ::ModelType,
    s::SamplerType,
    N::Integer;
    kwargs...
) where {ModelType<:Sampleable, SamplerType<:AbstractSampler}
    return DefaultCallback(N)
end

"""
    sample(
        ℓ::ModelType,
        s::SamplerType,
        N::Integer;
        kwargs...)

    sample(
        rng::AbstractRNG,
        ℓ::ModelType,
        s::SamplerType,
        N::Integer;
        kwargs...)

A generic interface for samplers.
"""
function sample(
    ℓ::ModelType,
    s::SamplerType,
    N::Integer;
    kwargs...
) where {ModelType<:Sampleable, SamplerType<:AbstractSampler}
    return sample(GLOBAL_RNG, ℓ, s, N)
end

"""
    sample(
        rng::AbstractRNG,
        ℓ::ModelType,
        s::SamplerType,
        N::Integer;
        kwargs...
    )

`sample` returns an `MCMCChains.Chains` object containing `N` samples from a given model and
sampler.
"""
function sample(
    rng::AbstractRNG,
    ℓ::ModelType,
    s::SamplerType,
    N::Integer;
    kwargs...
) where {ModelType<:Sampleable, SamplerType<:AbstractSampler}
    # Perform any necessary setup.
    sample_init!(rng, ℓ, s, N; kwargs...)

    # Preallocate the TransitionType vector.
    ts = transitions_init(rng, ℓ, s, N; kwargs...)

    # Add a progress meter.
    cb = init_callback(rng, ℓ, s, N; kwargs...)

    # Step through the sampler.
    for i=1:N
        if i == 1
            ts[i] = step!(rng, ℓ, s, N; kwargs...)
        else
            ts[i] = step!(rng, ℓ, s, N, ts[i-1]; kwargs...)
        end

        # Run a callback function.
        callback(rng, ℓ, s, N, i, cb; kwargs...)
    end

    # Wrap up the sampler, if necessary.
    sample_end!(rng, ℓ, s, N, ts; kwargs...)

    return Chains(rng, ℓ, s, N, ts; kwargs...)
end

"""
    sample_init!(
        rng::AbstractRNG,
        ℓ::ModelType,
        s::SamplerType,
        N::Integer;
        kwargs...
    )

Performs whatever initial setup is required for your sampler.
"""
function sample_init!(
    rng::AbstractRNG,
    ℓ::ModelType,
    s::SamplerType,
    N::Integer;
    kwargs...
) where {ModelType<:Sampleable, SamplerType<:AbstractSampler}
    # Do nothing.
    @warn "No sample_init! function has been implemented for objects
           of types $(typeof(ℓ)) and $(typeof(s))"
end

"""
    sample_end!(
        rng::AbstractRNG,
        ℓ::ModelType,
        s::SamplerType,
        N::Integer,
        ts::Vector{TransitionType};
        kwargs...
    )

Performs whatever finalizing the sampler requires.
"""
function sample_end!(
    rng::AbstractRNG,
    ℓ::ModelType,
    s::SamplerType,
    N::Integer,
    ts::Vector{TransitionType};
    kwargs...
) where {
    ModelType<:Sampleable,
    SamplerType<:AbstractSampler,
    TransitionType<:AbstractTransition
}
    # Do nothing.
    @warn "No sample_end! function has been implemented for objects
           of types $(typeof(ℓ)) and $(typeof(s))"
end

"""
    step!(
        rng::AbstractRNG,
        ℓ::ModelType,
        s::SamplerType,
        N::Integer;
        kwargs...
    )

Returns a single `AbstractTransition` drawn using the model and sampler type.
This is a unique step function called the first time a sampler runs.
"""
function step!(
    rng::AbstractRNG,
    ℓ::ModelType,
    s::SamplerType,
    N::Integer;
    kwargs...
) where {ModelType<:Sampleable, SamplerType<:AbstractSampler}
    # Do nothing.
    @warn "No step! function has been implemented for objects of types \n- $(typeof(ℓ)) \n- $(typeof(s))"
end

"""
    step!(
        rng::AbstractRNG,
        ℓ::ModelType,
        s::SamplerType,
        N::Integer,
        t::TransitionType;
        kwargs...
    )

Returns a single `AbstractTransition` drawn using the model and sampler type.
"""
function step!(
    rng::AbstractRNG,
    ℓ::ModelType,
    s::SamplerType,
    N::Integer,
    t::TransitionType;
    kwargs...
) where {ModelType<:Sampleable,
    SamplerType<:AbstractSampler,
    TransitionType<:AbstractTransition
}
    # Do nothing.
    # @warn "No step! function has been implemented for objects
    #        of types $(typeof(ℓ)) and $(typeof(s))"
    return step!(rng, ℓ, s, N; kwargs...)
end

"""
    step!(
        rng::AbstractRNG,
        ℓ::ModelType,
        s::SamplerType,
        N::Integer,
        t::Nothing;
        kwargs...
    )

Returns a single `AbstractTransition` drawn using the model and sampler type.
"""
function step!(
    rng::AbstractRNG,
    ℓ::ModelType,
    s::SamplerType,
    N::Integer,
    t::Nothing;
    kwargs...
) where {ModelType<:Sampleable,
    SamplerType<:AbstractSampler,
    TransitionType<:AbstractTransition
}
    @warn "No transition type passed in, running normal step! function."
    return step!(rng, ℓ, s, N; kwargs...)
end

"""
    transitions_init(
        rng::AbstractRNG,
        ℓ::ModelType,
        s::SamplerType,
        N::Integer;
        kwargs...
    )

Generates a vector of `AbstractTransition` types of length `N`.
"""
function transitions_init(
    rng::AbstractRNG,
    ℓ::ModelType,
    s::SamplerType,
    N::Integer;
    kwargs...
) where {ModelType<:Sampleable, SamplerType<:AbstractSampler}
    @warn "No transitions_init function has been implemented
           for objects of types $(typeof(ℓ)) and $(typeof(s))"
    return Vector(undef, N)
end

"""
    callback(
        rng::AbstractRNG,
        ℓ::ModelType,
        s::SamplerType,
        N::Integer,
        iteration::Integer,
        cb::CallbackType;
        kwargs...
    )

`callback` is called after every sample run, and allows you to run some function on a subtype of `AbstractCallback`. Typically this is used to increment a progress meter, show a plot of parameter draws, or otherwise provide information about the sampling process to the user.

By default, `ProgressMeter` is used to show the number of samples remaning.
"""
function callback(
    rng::AbstractRNG,
    ℓ::ModelType,
    s::SamplerType,
    N::Integer,
    iteration::Integer,
    cb::CallbackType;
    kwargs...
) where {
    ModelType<:Sampleable,
    SamplerType<:AbstractSampler,
    CallbackType<:AbstractCallback
}
    # Default callback behavior.
    ProgressMeter.next!(cb.p)
end

end # module Interface