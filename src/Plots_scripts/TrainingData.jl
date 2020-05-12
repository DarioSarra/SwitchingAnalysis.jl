using Revise
using SwitchingAnalysis
using HypothesisTests
using BrowseTables

## load
ongoing_dir = linux_gdrive
#ongoing_dir = mac_gdrive
files_loc = joinpath(ongoing_dir,files_dir)
figs_loc = joinpath(ongoing_dir,figs_dir)
fullS =  CSV.read(joinpath(files_loc,"streaks.csv"); types = columns_types) |> DataFrame
fullP =  CSV.read(joinpath(files_loc,"pokes.csv")) |> DataFrame
gr(size=(600,600), tick_orientation = :out, grid = false)
## filter and adjustments

fullP[!,:Protocol] = [ismissing(x) ? missing : string(x) for x in fullP[:,:Protocol]]
dropmissing!(fullP)
gd = groupby(fullP, [:Day,:MouseID,:Trial])
transform!(gd,:Reward => Pnext => :Pnextrew)
fullP[!,:InstRewRate] = fullP.Pnextrew ./ fullP.PokeDuration
pokes = filter(r-> !ismissing(r.Protocol) &&
    r.ExpDay > 5 &&
    r.Protocol in ["0.5","0.75","1.0"] &&
    r.Trial < 60 &&
    r.Phase == "training",
    fullP)

streaks = filter(r-> !ismissing(r.Protocol) &&
    r.ExpDay >5 &&
    r.Protocol in ["0.5","0.75","1.0"] &&
    r.Trial < 60 &&
    r.Num_pokes > 1 &&
    r.Phase == "training",
    fullS)

## Protocols Decay

Df = Prew(1:20)
Protocol_colors!(Df)
@df Df plot(:Poke, :Prew,
    group = :env, color = :color)
@df Df scatter!(:Poke, :Prew,
    group = :env, color = :color)
savefig(joinpath(figs_loc,"Fig2/A_ProtocolsDecay.pdf"))

## Rewards per trial

Df = combine(groupby(streaks,:Phase)) do dd
    summarize(dd,:Protocol,:Num_Rewards)
end
rename!(Df, :Xaxis=> :Protocol)
Protocol_colors!(Df)
@df Df groupedbar(:Protocol, :Mean,
    group = :Phase,
    yerror = :SEM,
    color = :color,
    legend = :topleft,
    yaxis = "Rewards per trial")
savefig(joinpath(figs_loc,"Fig2/B_RewardsPerProtocol.pdf"))

##

MVT(pokes)
savefig(joinpath(figs_loc,"Fig2/reward_rate.pdf"))
##
p = filter(r-> !ismissing(r.Protocol) &&
    r.ExpDay > 5 &&
    r.Protocol in ["0.5","0.75","1.0"] &&
    r.Treatment == "PreVehicle" &&
    r.Trial < 100,# &&
    #r.Phase == "training",
    fullP)
MVT(p)
savefig(joinpath(figs_loc,"Fig2/try_MVT_100trials.pdf"))


##
savefig(joinpath(figs_loc,"LeavingRewRate_AverageRewRate.pdf"))

##Bar plot of reward rate at leaving vs. average reward rate
pre_bar = stack(toplot,[:Average_mean,:Leaving_mean])
pre_bar[!,:x] = string.(pre_bar[:,:variable])

@df pre_bar boxplot(:x, :value, side=:right, fillalpha = 0.3)
savefig(joinpath(figs_loc,"boxplotLeaving_average.pdf"))

## testing leaving average reward equal to average reward rate

test = SignedRankTest(toplot[:,:Average_mean], toplot[:,:Leaving_mean])
annotate!(0.5, 0.7, string(pvalue(test)))
