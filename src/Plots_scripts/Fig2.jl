include("filtering.jl");
## Protocols Decay

Df = Prew(1:20)
Protocol_colors!(Df)
@df Df plot(:Poke, :Prew,
    group = :Protocol, linecolor = :color)
@df Df scatter!(:Poke, :Prew,
    group = :Protocol, color = :color)
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
savefig(joinpath(figs_loc,"Fig2/D1_reward_rate.pdf"))
MVT(pokes; group =:Phase)
savefig(joinpath(figs_loc,"Fig2/Phase_reward_rate.pdf"))

## Marginal value theorem bar plot
gd = groupby(pokes,[:Treatment,:MouseID,:Day,:Trial])
Rrate = combine([:InstRewRate, :AverageRewRate, :Reward] => (i,a,r) -> (Leaving = i[end],
    Average = a[end],
    Reward = r[end]),gd)
filter!(r -> r.Reward, Rrate)
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
        # ylims = (0,0.7),
        color = :color,
        label = false,
        yaxis = "Rewards rate") for subdf in gd]
ord = [1,5,4,2,7,9,8,6,3]
plot(tp[ord]...)
savefig(joinpath(figs_loc,"Fig2/D2_reward_rate.pdf"))

## Marginal value theorem SignedRankTest
df1 = combine(groupby(pokes,:Treatment)) do dd
    wilcoxon(dd,:InstRewRate,:AverageRewRate)
end
Drug_colors!(df1)
plot_wilcoxon(df1)
savefig(joinpath(figs_loc,"Fig2/D3_SignedRank_rewardrate.pdf"))

## Cumulative pokes before leaving
Df = combine(groupby(streaks,[:Treatment,:Protocol])) do dd
    ecdf(dd,:Num_pokes)
end
Protocol_colors!(Df)
gd = groupby(Df,:Treatment)
tp = [@df subdf plot(:Xaxis, :Mean,
    xlabel = :Treatment[1],
    group = :Protocol,
    linecolor = :color,
    color= :color,
    legend = false,
    ribbon = :ERR) for subdf in gd]
ord = [1,5,4,2,7,9,8,6,3]
plot(tp[ord]...)
savefig(joinpath(figs_loc,"Fig2/E_pokes_per_trial.pdf"))
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
        ylims = (0,18),
        yerror = :SEM,
        color = :color,
        legend = :topleft,
        label = false,
        yaxis = "Pokes per trial") for subdf in gd]
ord = [1,5,4,2,7,9,8,6,3]
plot(tp[ord]...)
savefig(joinpath(figs_loc,"Fig2/F_pokes_per_trial.pdf"))

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
    ribbon = :ERR,
    group = :Protocol,
    legend = false,
    color = :color,
    linecolor = :color,
    ylabel = "Cumulative",
    xlabel = "P reward at leaving \n $(:Treatment[1])"
    ) for subdf in gd]
ord = [1,5,4,2,7,9,8,6,3]
plot(tp[ord]...)
savefig(joinpath(figs_loc,"Fig2/G_pokes_per_trial.pdf"))

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
savefig(joinpath(figs_loc,"Fig2/H_PrewardatLeaving.pdf"))
##
