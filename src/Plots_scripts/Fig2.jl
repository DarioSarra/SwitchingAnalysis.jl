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
sort!(Df, (order(:Treatment, by = x-> Treatment_dict[x]),))
Treatment_dict
gd = groupby(Df,:Treatment)
toplot = [@df subdf bar(:Protocol, :Mean,
        xlabel = :Treatment[1],
        yerror = :SEM,
        color = :color,
        legend = :topleft,
        label = false,
        yaxis = "Rewards per trial") for subdf in gd]
plot(toplot...)
savefig(joinpath(figs_loc,"Fig2/B_RewardsPerProtocol.pdf"))

## Marginal value theorem scatter plot
MVT(pokes)
savefig(joinpath(figs_loc,"Fig2/D1reward_rate.pdf"))

## Marginal value theorem bar plot
gd = groupby(pokes,[:Treatment,:MouseID,:Day,:Trial])
Rrate = combine(:InstRewRate => i -> (Leaving = i[end],
    Average = mean(jump_missing(i))),gd)
df1 = stack(Rrate,[:Leaving,:Average])
rename!(df1, [:variable => :Rate_on, :value => :InstRewRate])
df2 = combine(groupby(df1,[:Treatment])) do dd
    summarize(dd,:Rate_on,:InstRewRate)
end
gd = groupby(df2,:Treatment)
toplot = [@df subdf bar(string.(:Xaxis), :Mean,
        xlabel = :Treatment[1],
        yerror = :SEM,
        color = :grey,
        label = false,
        yaxis = "Rewards rate") for subdf in gd]
plot(toplot...)
savefig(joinpath(figs_loc,"Fig2/D2reward_rate.pdf"))



## Number of pokes before leaving

Df = combine(groupby(streaks,:Treatment)) do dd
    summarize(dd,:Protocol,:Num_pokes)
end
rename!(Df, :Xaxis=>:Protocol)
Protocol_colors!(Df)
gd = groupby(Df,:Treatment)
toplot = [@df subdf bar(:Protocol, :Mean,
        xlabel = :Treatment[1],
        yticks = 0:1:20,
        ylims = (0,14),
        yerror = :SEM,
        color = :color,
        legend = :topleft,
        label = false,
        yaxis = "Pokes per trial") for subdf in gd]
plot(toplot...)

savefig(joinpath(figs_loc,"Fig2/Fpokes_per_trial.pdf"))

##Bar plot of reward rate at leaving vs. average reward rate
pre_bar = stack(toplot,[:Average_mean,:Leaving_mean])
pre_bar[!,:x] = string.(pre_bar[:,:variable])

@df pre_bar boxplot(:x, :value, side=:right, fillalpha = 0.3)
savefig(joinpath(figs_loc,"boxplotLeaving_average.pdf"))

## testing leaving average reward equal to average reward rate

test = SignedRankTest(toplot[:,:Average_mean], toplot[:,:Leaving_mean])
annotate!(0.5, 0.7, string(pvalue(test)))
