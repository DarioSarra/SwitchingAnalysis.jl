function Prew(protocol,poke::Int64)
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
