function mediansurvival_analysis(df,variable, grouping)
    dd1 = combine(groupby(df,[:MouseID,grouping]), variable => median => variable)
    dd2 = combine(groupby(dd1,grouping), variable => (t-> (Mean = mean(t),Sem = sem(t))) => AsTable)
    @df dd2 scatter(string.(cols(grouping)), :Mean, yerror = :Sem, xlims = (-0.25,2.25),
        xlabel = "Group", ylabel = "Median survival time", label = "")
end

function survivalrate_algorythm(variable; step = 0.05, xaxis = nothing)
    isnothing(xaxis) && (xaxis = range(extrema(variable)..., step = step))
    survival = 1 .- ecdf(variable).(xaxis)
    return (Xaxis = collect(xaxis), fy = survival)
end

function hazardrate_algorythm(variable; step = 0.05, xaxis = nothing)
    isnothing(xaxis) && (xaxis = range(extrema(variable)..., step = step))
    survival = 1 .- ecdf(variable).(xaxis)
    hazard = -pushfirst!(diff(survival),0)./survival
    return (Xaxis = collect(xaxis), fy = hazard)
end

function function_analysis(df,variable, f; grouping = nothing, step =0.05)
    subgroups = isnothing(grouping) ? [:MouseID] : vcat(:MouseID,grouping)
    xaxis = range(extrema(df[:, variable])..., step = step)
    dd1 = combine(groupby(df,subgroups), variable => (t-> f(t,xaxis = xaxis)) => AsTable)
    rename!(dd1, Dict(:Xaxis => variable))
    sort!(dd1,[:MouseID,variable])
    dd2 = combine(groupby(dd1,[grouping,variable]), :fy =>(t-> (Mean = mean(t),Sem = sem(t))) => AsTable)
    sort!(dd2,variable)
    @df dd2 plot(cols(variable),:Mean, ribbon = :Sem, group = cols(grouping))
        # xlabel = "Time (lo10 s)", ylabel = "Survival", label = "")
end
