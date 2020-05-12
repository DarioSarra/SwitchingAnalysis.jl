function summarize(dd::AbstractDataFrame,Xvar::Symbol,Yvar::Symbol; Err = :MouseID)
    ErrGroups = vcat(Xvar,Err)
    XaxisGroups = vcat(Xvar)
    pre_err = combine(groupby(dd, ErrGroups)) do df
        (Mean = mean(df[:,Yvar]),)
    end
    with_err = combine(groupby(pre_err,XaxisGroups)) do df
        (Mean = mean(df.Mean), SEM = sem(df.Mean))
    end
    rename(with_err, Xvar=>:Xaxis)
end

function StatsBase.ecdf(dd::AbstractDataFrame,Xvar::Symbol; Err = :MouseID)
    pre_err = combine(groupby(dd, Err)) do df
        F = ecdf(df[:,Xvar])
        (AN = F(F.sorted_values),Xaxis = F.sorted_values)
    end
    pre_err = flatten(pre_err,:AN)

    with_err = combine(groupby(pre_err,:Xaxis)) do df
        (Mean = mean(df.AN), SEM = sem(df.AN))
    end
    sort!(with_err,:Xaxis)
    dropnan!(with_err)
    return with_err
end

function MVT(df::AbstractDataFrame)
    gd = groupby(df,[:Phase,:MouseID,:Day,:Trial])
    Rrate = combine(:InstRewRate => x -> (Leaving = x[end], Average = mean(x)),gd)
    res = combine(groupby(Rrate,[:MouseID,:Phase]),:Leaving => mean, :Average => mean)
    plot([MVT_scatter(subdf) for subdf in groupby(res,:Phase)]...)
end

function MVT_scatter(toplot::AbstractDataFrame)
    if !in("Average_mean",names(toplot))
        println("missing Average reward rate column")
    else
        mdl = lm(@formula(Leaving_mean ~ Average_mean),toplot)
        a,b = round.(coeftable(mdl).cols[1],digits = 3)
        label =  toplot[1,:Phase]
        plt = @df toplot scatter(:Average_mean,:Leaving_mean,
            xlims = (0,1),
            ylims = (0,1),
            color = :grey,
            xlabel = "y = $a + $(b)x",
            title = label)
        Plots.abline!(1,0,color = :black)
        Plots.abline!(b,a,color = :red, legend = false)
        return plt
    end
end
# function MVT_scatter(x,y;label = "No label")
#     mdl = lm(x,y)
#     a,b = coeftable(mdl).cols[1]
#     # b = round((x'x)\(x'y),digits = 4)
#     # a = round(mean(y) - (b*mean(x)), digits = 4)
#     plt = scatter(x,y,
#         xlims = (0,1),
#         ylims = (0,1),
#         color = :grey,
#         xlabel = "y = $a + $(b)x",
#         ylabel =label)
#     Plots.abline!(1,0,color = :black)
#     Plots.abline!(b,a,color = :red, legend = false)
#     return plt
# end
