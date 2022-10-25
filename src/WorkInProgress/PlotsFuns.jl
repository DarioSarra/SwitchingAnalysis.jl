"""
    plot_perprotocol(df,var, treatment)
    Returns a plot were the mean + sem of `var` is plotted along the protocols
    only for `df` data belonging to `treatment`. The value "Control" is used for general behavior.
"""

function plot_perprotocol(df,var, treatment)
    df0 = filter(r-> r.Treatment == treatment, df)
    nrow(df0) == 0 && error("filtered out everything")
    df1 = combine(groupby(df0,[:Protocol,:MouseID]), var => mean => var)
    df2 = combine(groupby(df1,[:Protocol]), var .=> [mean, sem] .=> [:Mean, :SEM])
    sort!(df2, :Protocol)
    Protocol_colors!(df2)
    @df df2 scatter(:Mean, yerror = :SEM, color = :color, legend = false,
    xticks = ([1,2,3],["Hard", "Medium","Easy"]), xlims = (0.5,3.5))
end

"""
    plot_leave(df,treatment)

    plot mean + sem of average reward rate and reward rate at leaving
    for `df` data belonging to `treatment`. The value "Control" is used for general behavior.
"""
function plot_leave(df,treatment)
    df0 = filter(r-> r.Treatment == treatment && !r.LeaveWithReward && r.Trial <= 40 , df)
    nrow(df0) == 0 && error("filtered out everything")
    df1 = combine(groupby(df0,:MouseID),
        [:AverageRewRate, :LeavingRewRate] .=> mean .=> [:AverageRewRate, :LeavingRewRate])
    df2 = combine(df1,
        :AverageRewRate .=> [mean, sem] .=> [:AV_Mean, :AV_SEM],
        :LeavingRewRate .=> [mean, sem] .=> [:L_Mean, :L_SEM])
    df3 = DataFrame(Condition = ["Average", "At Leaving"],
        Mean = [df2[1,:AV_Mean], df2[1,:L_Mean]],
        SEM = [df2[1,:AV_SEM], df2[1,:L_SEM]])
    plt = @df df3 scatter(:Mean, yerror = :SEM, color = :grey, legend = false,
    xticks = ([1,2],["Average", "At Leaving"]))
    show(plt)
    return df3
end

"""
    plot_drugs(df,var)
    Returns a plot were the mean + sem of `var` is plotted along the protocols
    splitted by treatment
"""
function plot_drugs(df,var)
    df1 = transform(df, var => :Y)
    gd1 = groupby(df1,[:Protocol,:MouseID,:Phase,:Treatment])
    df2 = combine(gd1, :Y => mean => :Y)
    gd2 = groupby(df2,[:Protocol,:Treatment])
    df3 = combine(gd2, :Y .=> [mean, sem])
    Drug_colors!(df3)
    @df df3 scatter(:Protocol, :Y_mean, yerror = :Y_sem,
        group = :Treatment, color = :color,label = false,
        xticks = ([0.5,0.75,1],["Hard", "Medium","Easy"]), xlims = (0.4,1.1),
        xlabel = "Trial type")
end

"""
    plot_Ttest(df, var; xlims = (0,2))
    calls function Ttest_drugs to perform a Ttest on `var` for each drug in df
    then plots the results in a scatter with drugs along the x axys
"""
function plot_Ttest(df, var; kwargs...)
    tt = Ttest_drugs(df, var)
    res = collect_Ttest(tt)
    Drug_colors!(res)
    plt = @df res scatter(:Treatment, :Mean, yerror = :CI,
        color = :color, legend = false,
        xlabel = "Treatment"; kwargs...)
        Plots.abline!(0,0,color = :black, linestyle = :dash)
    show(plt)
    return plt, res
end
