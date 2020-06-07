"""
    'ODC!(pokes::AbstractDataFrame)'

Given the pokes Dataframe adds 2 columns
ODC: the ratio between each nose-poke’s duration and the sum of the duration and
the preceding inter-poke interval
PokeFromLeaving: An index about how many pokes are left in a given trial before
the animal left
"""

function ODC(pokes::AbstractDataFrame)
    df = copy(pokes)
    pn = propertynames(df)
    if !(:Pre_Interpoke in pn) || !(:PokeDuration in pn)
        error("Error in odc calculation, missing PreInterpoke or PokeDuration info")
    end
    df[!,:ODC] = [d/(d+i) for (d,i) in zip(df[:,:PokeDuration],df[:,:Pre_Interpoke])]
    gd = groupby(df,[:Day,:MouseID,:Trial])
    transform!(gd,:Poke => p -> collect(1:length(p)))
    rename!(df, :Poke_function => :PokeFromTrial)
    transform!(gd,:Poke => p -> collect(length(p)-1:-1:0))
    rename!(df, :Poke_function => :PokeFromLeaving)
    transform!(gd,:Reward => r -> count_from_last(r))
    rename!(df, :Reward_function => :PokeFromLastRew)
    return df
end

function count_from_last(v::AbstractVector)
    l = length(v)
    if l == 1
        return [missing]
    end
    last_r  = findlast(v)
    if isnothing(last_r)
        return missings(l)
    else
        return collect(1:l) .- last_r
    end
end

function calculate_odc(data::AbstractDataFrame,Phase::AbstractString,Allignment::Symbol)
    df0 = dropmissing(data,Allignment)
    # filter!(Allignment => a -> -limit < a < limit, df0)

    df1 =  filter(r -> !ismissing(r.ODC) &&
        !r.Reward &&
        r.Phase in [Phase],
        df0)

    df2 = combine(groupby(df1,:Treatment)) do dd
        summarize(dd,Allignment,:ODC)
    end
end

function calculate_odc(data::AbstractDataFrame,Allignment::Symbol; normalize = nothing)
    if !in(:ODC,propertynames(data))
        error("ODC column missing from data")
    end
    df0 = dropmissing(data,Allignment)
    df1 =  filter(r -> !ismissing(r.ODC) &&
        !r.Reward,
        df0)
    gd = groupby(df1,[:Phase,:Treatment,:MouseID, Allignment])
    df2 = combine(:ODC => mean,gd)
end
