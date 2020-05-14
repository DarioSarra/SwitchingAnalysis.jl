function _notnan!(res, col)
    @inbounds for (i, el) in enumerate(col)
        res[i] &= !isnan(el)
    end
    return nothing
end

function complete_vals(df::AbstractDataFrame, col::Colon=:)
    if ncol(df) == 0
        throw(ArgumentError("Unable to compute complete vals of a data frame with no columns"))
    end
    res = trues(size(df, 1))
    for i in 1:size(df, 2)
        _notnan!(res, df[!, i])
    end
    res
end

function complete_vals(df::AbstractDataFrame, col::DataFrames.ColumnIndex)
    res = trues(size(df, 1))
    _notnan!(res, df[!, col])
    res
end

complete_vals(df::AbstractDataFrame, cols::Union{AbstractVector, Regex, Not, Between, All}) =
    complete_vals(df[!, cols])

function dropnan(df::AbstractDataFrame, cols =:)
    newdf = df[complete_vals(df, cols), :]
    # disallowmissing && disallowmissing!(newdf, cols)
    newdf
end

function dropnan!(df::AbstractDataFrame,
                      cols=:)
    delete!(df, (!).(complete_vals(df, cols)))
    df
end

function Protocol_names!(df)
    df[!,:env] = map(x -> begin
                        if x == "0.5"
                            return "Low"
                        elseif x == "0.75"
                            return "Med."
                        elseif x == "1.0"
                            return "High"
                        else
                            return "weird"
                        end
                    end,
                    df.Protocol)
    return df
end

function Protocol_colors!(df)
    Protocol_names!(df)
    df[!,:color] = [get(protocol_colors,x,RGB(0,0,0)) for x in df.env]
    return df
end

function Drug_colors!(df)
    if :Treatment in propertynames(df)
        c = :Treatment
    elseif :Phase in propertynames(df)
        c = :Phase
    else
        error("didn't find any color to map")
    end
    df[!,:color] = [get(drug_colors,x,RGB(0,0,0)) for x in df[:,c]]
    return df
end

## calculate the extrema to filter the data out of the 95% of the distribution
conf95(v) = quantile(v,[0.25,0.975])

function conf_ints(vec; mode = :extrema, percent = 95)
    v = jump_missing(vec)
    p = (100 - percent) / 100
    if mode == :extrema
        p_half = p/2
        lower, upper = round.(quantile(v,[p_half,1-p_half]), digits = 3)
    elseif mode == :left
        lower = round.(quantile(v,p), digits = 3)
        upper = round(maximum(v), digits = 3) +1
    elseif mode == :right
        lower = round(minimum(v), digits = 3) -1
        upper = round.(quantile(v,1-p), digits = 3)
    else
        error("unknown confidence intervals mode")
    end
    return [lower,upper]
end

function trim_conf_ints(v; mode = :extrema, percent = 95)
    lower, upper = conf_ints(v; mode = mode, percent = percent)
    [ismissing(x) ? true : lower <= x <= upper for x in v]
end

function trim_conf_ints(df::AbstractDataFrame,x::Symbol; mode = :extrema, percent = 95)
    v = df[:,x]
    idxs = trim_conf_ints(v; mode = mode, percent = percent)
    df[idxs,:]
end

function trim_conf_ints!(df::AbstractDataFrame,x::Symbol; mode = :extrema, percent = 95)
    v = df[:,x]
    idxs = trim_conf_ints(v; mode = mode, percent = percent)
    delete!(df,Not(idxs))
end

function jump_missing(v::AbstractVector)
    res = v[map(!,ismissing.(v))]
    disallowmissing(res)
end

function jump_NaN(v::AbstractVector)
    res = v[map(!,isnan.(v))]
end
