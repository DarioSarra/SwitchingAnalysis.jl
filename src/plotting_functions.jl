function summarize(dd::AbstractDataFrame,Xvar::Symbol,Yvar::Symbol; Err = :MouseID)
    ErrGroups = vcat(Xvar,Err)
    XaxisGroups = vcat(Xvar)
    pre_err = combine(groupby(dd, ErrGroups)) do df
        (Mean = mean(df[:,Yvar]),)
    end
    with_err = combine(groupby(pre_err,XaxisGroups)) do df
        (Mean = mean(df.Mean), SEM = sem(df.Mean))
    end
    rename!(with_err, Xvar=>:Xaxis)
    sort!(with_err,:Xaxis)
    filter!(r -> !isnan(r.SEM), with_err)
end

function StatsBase.ecdf(dd::AbstractDataFrame,Xvar::Symbol; Err = :MouseID, mode = :sem)
    common_xaxis = ecdf(dd[:,Xvar]).sorted_values #new
    pre_err = combine(groupby(dd, Err)) do df
        F = ecdf(df[:,Xvar])
        #(AN = F(F.sorted_values),Xaxis = F.sorted_values) #old
        (AN = F(common_xaxis),Xaxis = common_xaxis) #new
    end
    pre_err = flatten(pre_err,:AN) #results retrn in a vector within a cell
    if mode == :sem
        with_err = combine(groupby(pre_err,:Xaxis)) do df
            (Mean = mean(df.AN), SEM = sem(df.AN))
        end
        sort!(with_err,:Xaxis)
    elseif mode == :conf_int    
        with_err = combine(groupby(pre_err,:Xaxis)) do df
            ci = confint(OneSampleTTest(df.AN))
            (Mean = mean(df.AN), SEMlow = ci[1], SEMup = ci[2])
        end
        with_err[!,:SEM] = [(low,up) for (low,up) in zip(with_err.SEMlow,with_err.SEMup)]
        sort!(with_err,:Xaxis)
    end
    #dropnan!(with_err)
    return with_err
end


function MVT_scatter(toplot::AbstractDataFrame; group = :Treatment)
    if !in("Average_mean",names(toplot))
        println("missing Average reward rate column")
    else
        mdl = lm(@formula(Leaving_mean ~ Average_mean),toplot)
        a,b = round.(coeftable(mdl).cols[1],digits = 3)
        label =  toplot[1, group]
        plt = @df toplot scatter(:Average_mean,:Leaving_mean,
            ylims = (0,ceil(maximum(:Leaving_mean),digits = 1)+0.1),
            xlims = (0,ceil(maximum(:Leaving_mean),digits = 1)+0.1),
            color = :grey,
            xlabel = "y = $a + $(b)x",
            title = label)
        Plots.abline!(1,0,color = :black)
        Plots.abline!(b,a,color = :red, legend = false)
        return plt
    end
end

function MVT(df::AbstractDataFrame; group = :Treatment)
    gd = groupby(df,[group,:MouseID,:Day,:Trial])
    Rrate = combine([:InstRewRate, :AverageRewRate, :Reward] => (i,a,r) -> (Leaving = i[end],
        Average = a[end],
        Reward = r[end]),gd)
    filter!(r -> r.Reward, Rrate)
    gd = groupby(Rrate,[:MouseID,group])
    res = combine([:Leaving,:Average] => (l,a) ->(Leaving_mean = mean(jump_missing(l)), Average_mean = mean(jump_NaN(a))), gd)
    tp = [MVT_scatter(subdf; group = group) for subdf in groupby(res,group)]
    if group == :Treatment
        ord = [1,5,4,2,7,9,8,6,3]
        return plot(tp[ord]...)
    else
        return plot(tp...)
    end
end

function MVT_meanInstRew(df::AbstractDataFrame; group = :Treatment)
    gd = groupby(df,[group,:MouseID,:Day,:Trial])
    Rrate = combine([:InstRewRate, :Reward] => (i,r) -> (Leaving = i[end],
        Average = mean(jump_missing(i)),
        Reward = r[end]),gd)
    #filter!(r -> !r.Reward, Rrate)
    gd = groupby(Rrate,[:MouseID,group])
    res = combine([:Leaving,:Average] => (l,a) ->(Leaving_mean = mean(jump_missing(l)), Average_mean = mean(jump_NaN(a))), gd)
    tp = [MVT_scatter(subdf) for subdf in groupby(res,group)]
    ord = [1,5,4,2,7,9,8,6,3]
    plot(tp[ord]...)
end
