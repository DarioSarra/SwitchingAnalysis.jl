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
    deleterows!(df, (!).(complete_vals(df, cols)))
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
