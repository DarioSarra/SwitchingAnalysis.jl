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
    transform!(gd,:Poke => p -> collect(length(p)-1:-1:0))
    rename!(df, :Poke_function => :PokeFromLeaving)
    return df
end
