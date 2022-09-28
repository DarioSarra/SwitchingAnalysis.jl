function summarize(dd::AbstractDataFrame,Xvar::Symbol,Yvar::Symbol; Err = :MouseID , mode = :sem)
    ErrGroups = vcat(Xvar,Err)
    XaxisGroups = vcat(Xvar)
    pre_err = combine(groupby(dd, ErrGroups)) do df
        (Mean = mean(df[:,Yvar]),)
    end
    if mode == :sem
        with_err = combine(groupby(pre_err,XaxisGroups)) do df
            (Mean = mean(df.Mean), SEM = sem(df.Mean))
        end
        rename!(with_err, Xvar=>:Xaxis)
        sort!(with_err,:Xaxis)
        filter!(r -> !isnan(r.SEM), with_err)
    elseif mode == :conf
        with_err = combine(groupby(pre_err,XaxisGroups)) do df
            ci = confint(OneSampleTTest(df.Mean))
            m = mean(df.Mean)
            (Mean = m, ERRlow = m - ci[1], ERRup = ci[2] - m)
        end
        with_err[!,:ERR] = [(low,up) for (low,up) in zip(with_err.ERRlow,with_err.ERRup)]
        rename!(with_err, Xvar=>:Xaxis)
        sort!(with_err,:Xaxis)
    end
    return with_err
end

function summarize_xy(df0, xvar, yvar; group = nothing, err = :MouseID, kwargs...)
    mean_grouping = isnothing(group) ? [xvar] : vcat(xvar,group)
    err_grouping = vcat(mean_grouping,err)
    df1 = combine(groupby(df0,err_grouping), yvar => mean => yvar)
    df2 = combine(groupby(df1,mean_grouping), yvar .=> [mean, sem] .=> [:Mean, :SEM])
    try
        Drug_colors!(df2)
    catch e
        println(e)
        df2[!,:color] .= RGB(0.0,0.0,0.0)
    end
    dropnan!(df2)

    if isnothing(group)
        return @df df2 plot(cols(xvar), :Mean, ribbon = :SEM,
            color = :color, linecolor = :color; kwargs...)
    else
        return @df df2 plot(cols(xvar), :Mean, ribbon = :SEM, group = cols(group),
            color = :color, linecolor = :color; kwargs...)
    end
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
            (Mean = mean(df.AN), ERR = sem(df.AN))
        end
        sort!(with_err,:Xaxis)
    elseif mode == :conf
        with_err = combine(groupby(pre_err,:Xaxis)) do df
            ci = confint(OneSampleTTest(df.AN))
            m = mean(df.AN)
            (Mean = m, ERRlow = m - ci[1], ERRup = ci[2] - m)
        end
        with_err[!,:ERR] = [(low,up) for (low,up) in zip(with_err.ERRlow,with_err.ERRup)]
        sort!(with_err,:Xaxis)
    end
    #dropnan!(with_err)
    return with_err
end

function frequency(df::AbstractDataFrame,Xvar::Symbol; Err = :MouseID, mode = :sem)
    pre_err = combine(groupby(df, Err)) do dd
        dx = countmap(dd[:, Xvar])
        val = []
        freq = []
        for (k,v) in dx
            push!(val, k)
            push!(freq,v)
        end
        DataFrame(Xaxis = val, Freq = freq./nrow(dd))
    end
    with_err = combine(groupby(pre_err,:Val), :Freq .=> (mean,sem) .=> [:Mean, :ERR])
    dropnan!(with_err)
    sort!(with_err,:Xaxis)

end

function effect_size(df::AbstractDataFrame,Effectvar::Symbol,Yvar::Symbol; Err = :MouseID, baseline = nothing)
    if length(union(df[:,Effectvar])) != 2
        error("Effect variable has more than 2 levels")
    end
    if baseline == nothing
        baseline = sort(union(sort(df[:,Effectvar])))[end]
    end
    gd = groupby(df,[Effectvar,Err])
    df1 = combine(Yvar => mean => :Mean,gd)
    df2 = unstack(df1,Effectvar,:Mean)
    manipulation = filter(x -> x != baseline ,union(df[:,Effectvar]))[1]
    df2[!,:Effect] = df2[:,Symbol(manipulation)] - df2[:,Symbol(baseline)]
    df2[!, :Calculation] .= string(manipulation," - ", baseline)
    deletecols!(df2,[Symbol(manipulation), Symbol(baseline)])
    return df2
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
        Plots.abline!(b,a,linecolor = :red, legend = false)
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

function plot_wilcoxon(dd; color = nothing , sorting = nothing, showmice = true)
    if isnothing(sorting)
        sorting = Dict()
        for (v,k) in enumerate(sort(dd[:,1]))
            sorting[k] = v
        end
    end
    position = []
    original = []
    for (k,v) in sorting
        if k in dd[:,1]
            push!(position,v)
            push!(original,k)
        end
    end
    dd[!,:x] = [get(sorting,x,0) for x in dd[:,1]]
    dd2 = flatten(dd,:Vals)
    if showmice
        @df dd2 scatter(:x, :Vals,
            color = :grey,
            markeralpha = 0.4,
            markercolor = :grey)
    else
        plot()
    end
    Plots.abline!(0,0,color = :black, linestyle = :dash)
    if isnothing(color)
        c = :color in propertynames(dd) ? dd[:,:color] : :auto
    else
        c = color
    end
    @df dd scatter!(:x,:Median,
        yerror = :CI,
        linecolor = :black,
        markerstrokecolor = :black,
        markersize = 8,
        legend = false,
        tickfont = (7, :black),
        xlims = (minimum(:x) - 0.5, maximum(:x) + 0.5),
        xticks = (position,original),
        color = c,
        thickness_scaling = 2,
        guidefontsize = 8,
        ylabel = "Signed rank test - median and 95% c.i.")
end

function WebersLaw(df,x,group)
    group_vars = vcat(:MouseID,group)
    gd = groupby(df,group_vars)
    df1 = combine([x] => a -> (Mean = mean(a), STD = std(a)), gd)
    Drug_colors!(df1)
    plt = @df df1 scatter(:Mean,:STD, color = :color,
        markersize = 5, group = :Treatment, legend = :topleft,
        xlims = (0,13), ylims = (0,13))
    Plots.abline!(1,0, linestyle = :dash, xlabel = "Mean pokes after last reward", ylabel = "STD pokes after last reward", label = nothing)
    combine(groupby(df1,group)) do dd
        mdl = lm(@formula(STD ~ Mean),dd)
        a,b = round.(coeftable(mdl).cols[1],digits = 3)
        Plots.abline!(b,a, linewidth = 2, linecolor = dd[1,:color], label = "y = $(b)x + $a")
    end
    return plt
end

function plot_wilcoxon_odc(data::AbstractDataFrame,Phase::AbstractString,Allignment::Symbol; limit = 6, color = nothing)

    df0 = dropmissing(data,Allignment)
    filter!(Allignment => a -> -limit < a < limit, df0)

    df1 =  filter(r -> !ismissing(r.ODC) &&
        !r.Reward &&
        r.Phase in [Phase],
        df0)

    df2 = unstack(df1,:Treatment,:ODC)

    gd = groupby(df2,[Allignment,:MouseID])
    df3 = combine([:Control,Symbol(Phase)] => (c,d) ->
        (Control = mean(skipmissing(c)), Treatment = mean(skipmissing(d))),gd)

    df4 = combine(groupby(df3,[Allignment])) do dd
        wilcoxon(dd,:Treatment, :Control; f = x -> mean(skipmissing(x)))
    end
    plot_wilcoxon(df4; color = color)
end

function plot_wilcoxon_odc(data::AbstractDataFrame,Phases::AbstractVector{<:AbstractString},Allignment::Symbol; limit = 6, color = nothing)
    ps = []
    for phase in Phases
        c = get(drug_colors,phase,:grey)
        p = plot_wilcoxon_odc(data,phase,Allignment; limit = limit, color = c)
        title!(phase)
        ylabel!("")
        push!(ps,p)
    end
    hight_layout = Int64(round(sqrt(length(ps))))
    width_layout = Int64(ceil(length(ps) / hight_layout))

    for i in (1:width_layout:length(ps) )
        ylabel!(ps[i], "Signed rank test ODC")
    end
    plot(ps..., xlabel = string(Allignment))
end

function plot_odc(data::AbstractDataFrame,Phase::AbstractString,Allignment::Symbol; limit = 6)

    df0 = dropmissing(data,Allignment)
    filter!(Allignment => a -> -limit < a < limit, df0)

    df1 =  filter(r -> !ismissing(r.ODC) &&
        !r.Reward &&
        r.Phase in [Phase],
        df0)

    df2 = combine(groupby(df1,:Treatment)) do dd
        summarize(dd,Allignment,:ODC)
    end

    Drug_colors!(df2)
    @df df2 scatter(:Xaxis, :Mean,
        yerror = :SEM,
        group = :Treatment,
        color = :color,
        legend = false)
end

function plot_odc(data::AbstractDataFrame,Phases::AbstractVector{<:AbstractString},Allignment::Symbol; limit = 6)
    ps = []
    for phase in Phases
        p = plot_odc(data, phase,Allignment; limit = limit)
        title!(phase)
        push!(ps,p)
    end
    hight_layout = Int64(round(sqrt(length(ps))))
    width_layout = Int64(ceil(length(ps) / hight_layout))
    for i in (1:width_layout:length(ps) )
        ylabel!(ps[i], "ODC")
    end
    plot(ps..., xlabel = string(Allignment))
end

function odc_regression(data::AbstractDataFrame,phase::AbstractVector{<:AbstractString})
    df1 = filter(r -> r.Phase in phase,data)
    df2 = combine(groupby(df1,:Manipulation)) do dd
        summarize(dd, :PokeFromLastRew,:ODC)
    end
    df2[!, :color] = [get(drug_colors,r,:grey) for r in df2.Manipulation]
    @df df2 plot(:Xaxis, :Mean, ribbon = :SEM,
        group = :Manipulation,
        xlabel = "Poke from Last Reward",
        ylabel = "Omission duty cycle",
        xticks = 1:30,
        fillalpha = 0.2,
        linewidth = 3,
        color = :color,
        linecolor = :color)
end

function plot_deltafromrew(df, phase; limit = 15)
    gd = groupby(df,[:PokeFromLastRew])
    df1 = combine(gd,:DeltaCitalopram => skipmean => :DeltaCitalopram,
        :DeltaOptogenetic => skipmean => :DeltaOptogenetic,
        :DeltaAltanserin=> skipmean => :DeltaAltanserin,
        :DeltaSB242084 => skipmean => :DeltaSB242084)
    c_name = "Delta" * phase
    c_symbol = Symbol(c_name)
     @df filter(r -> r.PokeFromLastRew < limit, df) scatter(:PokeFromLastRew, cols(c_symbol), markercolor = :grey)
    @df filter(r -> r.PokeFromLastRew < limit, df1) scatter!(:PokeFromLastRew, cols(c_symbol), markersize = 8, markercolor = get(drug_colors,phase,:red))
    Plots.abline!(0,0, legend = false,
        ylims = (-0.1,0.1),
        xticks = 1:20, xlabel = "Poke from last reward", ylabel = "ODC delta " * phase)
end

function plot_QODC(df, allignment; xflip = false, legend = false, ylims = (3,12))
    gd1 = groupby(df,[:Phase,:MouseID,allignment,:Treatment])
    df1 = combine(gd1, :QODC => mean)
    gd2 = groupby(df1,[:Phase,allignment,:Treatment])
    df2 = combine(gd2, :QODC_mean => mean => :QODC_mean, :QODC_mean => sem => :QODC_sem)
    plts = []
    Drug_colors!(df2)
    combine(groupby(df2,:Phase)) do dd
        p = @df dd scatter(cols(allignment), :QODC_mean, yerror = :QODC_sem,
        group = :Treatment, color = :color, xflip = xflip, legend = legend,
        xticks = 0:20, yticks = 0:20, ylims = ylims,
        markersize = 4,
        thickness_scaling = 2,
        guidefontsize = 8,
        ylabel = "Omissions duty cycle quantile")
        push!(plts,p)
    end
    plot(plts...)
end
