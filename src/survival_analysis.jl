function mediansurvival_analysis(df,variable, grouping)
    dd1 = combine(groupby(df,[:MouseID,grouping]), variable => median => variable)
    dd2 = combine(groupby(dd1,grouping), variable => (t-> (Mean = mean(t),Sem = sem(t))) => AsTable)
    plt = @df dd2 scatter(string.(cols(grouping)), :Mean, yerror = :Sem,
        xlabel = "Group", ylabel = "Median survival time", label = "")
    return dd2, plt
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
end

function survival_analysis(df,times,events;grouping = nothing, step =0.05)
    subgroups = isnothing(grouping) ? [:MouseID] : vcat(:MouseID,grouping)
    xaxis = range(extrema(df[:, times])..., step = step)
    dd1 = combine(groupby(df,subgroups), [times, events] => ((t,e)-> _survival(t,e; axis = xaxis)) => AsTable)
    rename!(dd1, Dict(:Xaxis => times))
    sort!(dd1,[:MouseID,times])
    subgroups2 = isnothing(grouping) ? [times] : vcat(times,grouping)
    dd2 = combine(groupby(dd1,subgroups2), :SurvRate =>(t-> (Mean = mean(t),Sem = sem(t))) => AsTable)
    sort!(dd2,times)
    return dd2
end

function _survival(times, events; axis = extrema(time), kwargs...)
    km = fit(KaplanMeier, times, events)
    surv = zeros(length(axis))
    for (i, ax) in enumerate(axis)
        if ax < km.times[1]
            surv[i] = 1
        elseif ax > km.times[end]
            surv[i] = km.survival[end]
        else
            surv[i] = km.survival[searchsortedfirst(km.times, ax)]
        end
    end
    return (Xaxis = collect(axis), SurvRate = surv)
end

function KM_median(KM::T) where T <:KaplanMeier
    idx = findfirst(KM.survival .< 0.5)
    isnothing(idx) ? missing : KM.times[idx-1]
end
