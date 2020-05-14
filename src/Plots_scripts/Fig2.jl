include("filtering.jl");
## Protocols Decay

Df = Prew(1:20)
Protocol_colors!(Df)
@df Df plot(:Poke, :Prew,
    group = :env, color = :color)
@df Df scatter!(:Poke, :Prew,
    group = :env, color = :color)
savefig(joinpath(figs_loc,"Fig2/A_ProtocolsDecay.pdf"))

## Rewards per trial

Df = combine(groupby(streaks,:Treatment)) do dd
    summarize(dd,:Protocol,:Num_Rewards)
end
rename!(Df, :Xaxis=>:Protocol)
Protocol_colors!(Df)
gd = groupby(Df,:Treatment)
tp = [@df subdf bar(:Protocol, :Mean,
        xlabel = :Treatment[1],
        yerror = :SEM,
        color = :color,
        legend = false,
        yaxis = "Rewards per trial") for subdf in gd]
ord = [1,5,4,2,7,9,8,6,3]
plot(tp[ord]...)
savefig(joinpath(figs_loc,"Fig2/B_RewardsPerProtocol.pdf"))

## Marginal value theorem scatter plot
MVT(pokes)
savefig(joinpath(figs_loc,"Fig2/D1reward_rate.pdf"))
MVT(pokes; group =:Phase)
savefig(joinpath(figs_loc,"Fig2/Phase_reward_rate.pdf"))
p = filter(r-> r.Trial <30,pokes)
MVT(p)
savefig(joinpath(figs_loc,"Fig2/MVT30.pdf"))
## Marginal value theorem bar plot
gd = groupby(pokes,[:Treatment,:MouseID,:Day,:Trial])
Rrate = combine(:InstRewRate => i -> (Leaving = i[end],
    Average = mean(jump_missing(i))),gd)
df1 = stack(Rrate,[:Leaving,:Average])
rename!(df1, [:variable => :Rate_on, :value => :InstRewRate])
df2 = combine(groupby(df1,[:Treatment])) do dd
    summarize(dd,:Rate_on,:InstRewRate)
end
Drug_colors!(df2)
gd = groupby(df2,:Treatment)
tp = [@df subdf bar(string.(:Xaxis), :Mean,
        xlabel = :Treatment[1],
        yerror = :SEM,
        ylims = (0,0.7),
        color = :color,
        label = false,
        yaxis = "Rewards rate") for subdf in gd]
ord = [1,5,4,2,7,9,8,6,3]
plot(tp[ord]...)
savefig(joinpath(figs_loc,"Fig2/D2reward_rate.pdf"))

## Marginal value theorem bar plot
gd = groupby(pokes,[:Treatment,:MouseID,:Day,:Trial])
Rrate = combine(:InstRewRate => i -> (Leaving = i[end],
    Average = mean(jump_missing(i))),gd)
df1 = stack(Rrate,[:Leaving,:Average])
rename!(df1, [:variable => :Rate_on, :value => :InstRewRate])
df2 = combine(groupby(df1,[:Treatment])) do dd
    summarize(dd,:Rate_on,:InstRewRate)
end
Drug_colors!(df2)
gd = groupby(df2,:Treatment)
tp = [@df subdf bar(string.(:Xaxis), :Mean,
        xlabel = :Treatment[1],
        yerror = :SEM,
        ylims = (0,0.7),
        color = :color,
        label = false,
        yaxis = "Rewards rate") for subdf in gd]
ord = [1,5,4,2,7,9,8,6,3]
plot(tp[ord]...)
savefig(joinpath(figs_loc,"Fig2/D2reward_rate.pdf"))
## Cumulative pokes before leaving

Df = combine(groupby(streaks,[:Treatment,:Protocol])) do dd
    ecdf(dd,:Num_pokes)
end
Protocol_colors!(Df)
gd = groupby(Df,:Treatment)
tp = [@df subdf plot(:Xaxis, :Mean,
    xlabel = :Treatment[1],
    group = :Protocol,
    color = :color,
    legend = false,
    ribbon = :SEM) for subdf in gd]
ord = [1,5,4,2,7,9,8,6,3]
plot(tp[ord]...)
savefig(joinpath(figs_loc,"Fig2/Epokes_per_trial.pdf"))
## Number of pokes before leaving

Df = combine(groupby(streaks,:Treatment)) do dd
    summarize(dd,:Protocol,:Num_pokes)
end
rename!(Df, :Xaxis=>:Protocol)
Protocol_colors!(Df)
gd = groupby(Df,:Treatment)
tp = [@df subdf bar(:Protocol, :Mean,
        xlabel = :Treatment[1],
        yticks = 0:2:20,
        ylims = (0,14),
        yerror = :SEM,
        color = :color,
        legend = :topleft,
        label = false,
        yaxis = "Pokes per trial") for subdf in gd]
ord = [1,5,4,2,7,9,8,6,3]
plot(tp[ord]...)
savefig(joinpath(figs_loc,"Fig2/Fpokes_per_trial.pdf"))

## testing leaving average reward equal to average reward rate

test = SignedRankTest(toplot[:,:Average_mean], toplot[:,:Leaving_mean])
annotate!(0.5, 0.7, string(pvalue(test)))

## P reward at leaving cumulative
gd = groupby(pokes,[:Treatment,:MouseID,:Day,:Protocol,:Trial])
Rrate = combine(:Pnextrew => i -> (RewRateLeaving = i[end],),gd)
gd = groupby(Rrate,[:Treatment,:Protocol])
Df = combine(gd) do dd
    ecdf(dd,:RewRateLeaving)
end
Protocol_colors!(Df)
gd = groupby(Df,:Treatment)
tp = [@df subdf plot(:Xaxis, :Mean,
    # xlabel = :Treatment[1],
    ribbon = :SEM,
    group = :Protocol,
    legend = false,
    color = :color,
    ylabel = "Cumulative probability",
    xlabel = "P reward at leaving \n $(:Treatment[1])"
    ) for subdf in gd]
ord = [1,5,4,2,7,9,8,6,3]
plot(tp[ord]...)
savefig(joinpath(figs_loc,"Fig2/Gpokes_per_trial.pdf"))

## P reward at leaving bar plot
gd = groupby(pokes,[:Treatment,:MouseID,:Day,:Protocol,:Trial])
Rrate = combine(:Pnextrew => i -> (RewRateLeaving = i[end],),gd)
gd = groupby(Rrate,[:Treatment])
Df = combine(gd) do dd
    summarize(dd,:Protocol,:RewRateLeaving)
end
rename!(Df, :Xaxis=>:Protocol)
Protocol_colors!(Df)
gd = groupby(Df,:Treatment)
tp = [@df subdf bar(:Protocol, :Mean,
        xlabel = :Treatment[1],
        yerror = :SEM,
        ylims = (0,0.25),
        color = :color,
        legend = :topleft,
        label = false,
        yaxis = "P reward at leaving") for subdf in gd]
ord = [1,5,4,2,7,9,8,6,3]
plot(tp[ord]...)
savefig(joinpath(figs_loc,"Fig2/Hpokes_per_trial.pdf"))
