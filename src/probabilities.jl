function Prew(protocol::Float64,poke::Int64)
    protocol*(ℯ^(-(poke-1)/5))
end

function Prew(protocol,poke::AbstractVector{Int64})
    Prew.(protocol,poke)
end

function Prew(protocol,poke::UnitRange{Int64})
    Prew.(protocol,collect(poke))
end

function Prew(poke::UnitRange{Int64})
    df = DataFrame(Poke = Int64[], Prew = Float64[], Protocol = String[])
    for protocol in [1.0,0.75,0.5]
        dd = DataFrame(Poke = collect(poke), Prew = Prew.(protocol,collect(poke)))
        dd[!,:Protocol] .= string(protocol)
        append!(df,dd)
    end
    return df
end
"""
    Poutcome(outcome, poke, protocol)

Compute the probability of a positive or negative outcome at the nth poke
for a given protocol
"""
function Poutcome(outcome::Bool,poke::Int64,protocol::Float64)
    if outcome
        return Prew(protocol,poke)
    elseif !outcome
        return 1 - Prew(protocol,poke)
    end
end

"""
    Pobservation(observations,protocol)

Compute the probability of a specific sequence of observation for a given
protocol
"""
function Pobservations(observations::AbstractVector{Bool},protocol::Float64)
    cumprod([Poutcome(o,p,protocol) for (p,o) in enumerate(observations)])
end

function Pobservations_lastval(observations::AbstractVector{Bool},protocol::Float64)
    cumprod([Poutcome(o,p,protocol) for (p,o) in enumerate(observations)])[end]
end


"""
    Pprotocol(protocol,observations)

Compute the probability of the current trial being equal to protocol
given a series of (observations). Compute the probability of a series of
observation to be genrated by the specified scaling factor (protocol)
given the 3 possible protocol type (0.5,0.75,1.0)

"""
function Pprotocol(protocol::Float64,observations::AbstractVector{Bool})
    possibleprotocols = Pobservations(observations,0.5) +
        Pobservations(observations,0.75) +
        Pobservations(observations,1.0)
    Pobservations(observations,protocol)./possibleprotocols
end

function Pprotocol_lastval(protocol::Float64,observations::AbstractVector{Bool})
    possibleprotocols = Pobservations(observations,0.5) +
        Pobservations(observations,0.75) +
        Pobservations(observations,1.0)
    Pobservations(observations,protocol)/possibleprotocols
end

"""
    Pnext(observations)

Compute the probability of the next poke to be rewarded after a series of
observations and given the 3 possible protocol type (0.5,0.75,1.0)

"""
function Pnext(observations::AbstractVector{Bool})
    res = zeros(length(observations))
    for prot in [0.5,0.75,1.00]
        res += Prew(prot,2:length(observations)+1) .* Pprotocol(prot,observations)
    end
    return res
end

function Pnext_lastval(observations::AbstractVector{Bool})
    res = 0
    for prot in [0.5,0.75,1.00]
        res += Prew(prot,length(observations)+1) * Pprotocol(prot,observations)
    end
    return res
end
