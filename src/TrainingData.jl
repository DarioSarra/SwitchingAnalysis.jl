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
    r.Trial < 60,# &&
    #r.Phase == "training",
    fullP)

streaks = filter(r-> !ismissing(r.Protocol) &&
    r.ExpDay >5 &&
    r.Protocol in ["0.5","0.75","1.0"] &&
    r.Trial < 30 &&
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


## Add Instantenous reward rate

p =  dropmissing(pokes, disallowmissing = true)
@df filter(r -> r.PokeDuration < 3, p) density(:PokeDuration)
gd = groupby(p, [:Day,:MouseID,:Trial])
transform!(gd,:Reward => Pnext => :Pnextrew)
p[!,:InstRewRate] = p.Pnextrew ./ p.PokeDuration
open_html_table(p[1:50,[:Protocol,:Trial,:Reward,
    :PokeDuration,:Pnextrew,:InstRewRate]])
@df p density(:InstRewRate)

## Scatter plot of reward rate at leaving over average reward rate

gd = groupby(pokes,[:Phase,:MouseID,:Day,:Trial])
Rrate = combine(:InstRewRate => x -> (Leaving = x[end], Average = mean(x)),gd)
res = combine(groupby(Rrate,[:MouseID,:Phase]),:Leaving => mean, :Average => mean)

toplot = filter(r-> r.Phase == "training",res)
@df toplot scatter(:Average_mean,:Leaving_mean,
    xlims = (0,1),
    ylims = (0,1),
    color = :grey)
Plots.abline!(1,0,color = :black)
x = toplot[:,:Average_mean]
y = toplot[:,:Leaving_mean]
b = round((x'x)\(x'y),digits = 5)
a = round(mean(y) - (b*mean(x)), digits = 5)
Plots.abline!(b,a,color = :red, legend = false)
annotate!(0.1, 0.8, "y = $a + $(b)x",:left)
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
