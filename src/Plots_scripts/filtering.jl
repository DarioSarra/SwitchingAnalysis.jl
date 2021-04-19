## Script to determine values for filtering the datasets

using Revise
using SwitchingAnalysis
using HypothesisTests
using BrowseTables
using Plots.PlotMeasures

## load
if ispath(linux_gdrive)
    ongoing_dir = linux_gdrive
else
    ongoing_dir = mac_gdrive
end

files_loc = joinpath(ongoing_dir,files_dir)
figs_loc = joinpath(ongoing_dir,figs_dir)
fullS =  DataFrame(CSV.read(joinpath(files_loc,"streaks.csv"); types = columns_types))
fullP =  DataFrame(CSV.read(joinpath(files_loc,"pokes.csv")))
gr(size=(600,600), tick_orientation = :out, grid = false, linecolor = :black,
markerstrokecolor = :black)
## removing irrelevant events and computes relevant variables for pokes dataframe

# turning Protocol from Float to string to allow for categorical analysis
fullP[!,:Protocol] = [ismissing(x) ? missing : string(x) for x in fullP[:,:Protocol]]
pokes = filter(r-> !ismissing(r.Protocol) &&
    r.ExpDay > 5 && #remove early training days
    r.Protocol in ["0.5","0.75","1.0"], #remove protocol "0.0": an exeption for wrong trials
    fullP)
#removing events when the animal travel to a patch but doesn't poke
pokes =  dropmissing(pokes, :Poke)
disallowmissing!(pokes, :Reward)
# computing the probability of next poke to be a reward and instanteneous reward rate
pokes[!,:Next_Prew] = [Prew(parse(Float64,prot) + 1,Int64(pok)) for (prot,pok) in zip(pokes.Protocol,pokes.Poke_within_Trial)]
gd = groupby(pokes, [:Day,:MouseID,:Trial])
transform!(gd,:Reward => Pnext => :Pnextrew)
# calculate time interval from previous poke out to current poke out
poke_time = [ismissing(i) ? d : i+d for (i,d) in zip( pokes.Pre_Interpoke, pokes.PokeDuration)]
pokes[!,:InstRewRate] = pokes.Pnextrew ./ poke_time
#calculate elapsed time and cumulative reward from the first poke in
gd = groupby(pokes, [:Day,:MouseID])
transform!(gd,[:PokeIn,:PokeOut,] => (i,o) -> o .- i[1])
rename!(pokes, :PokeIn_PokeOut_function => :ElapsedTime)
transform!(gd,:Reward => cumsum => :Cumulative_Reward)
# calculate average reward rate for each poke cumulative reward / elapsed time
pokes[!,:AverageRewRate] = 1 ./ (pokes.ElapsedTime ./ pokes.Cumulative_Reward)
# calculate time elapsed from the last pokeout of the previous trial
pokes[!,:TimeFromLeaving] = zeros(nrow(pokes))
gd1 = groupby(pokes,[:MouseID,:Day])
combine(gd1) do dd
    dd[:,:TimeFromLeaving] = TimeFromLeaving(dd)
end
nbins = 200
lr = LinRange(0,60,nbins)
pokes[!,:TimeFromLeaving] = [isnothing(findfirst( x .< lr)) ? round(nbins * step(lr), digits = 1) : round(findfirst( x .< lr) * step(lr), digits = 1) for x in pokes.TimeFromLeaving]
pokes[!,:CumRewTrial] = Vector{Float64}(undef,nrow(pokes))
gd2 = groupby(pokes,[:Trial,:MouseID,:Day])
combine(gd2) do dd
    dd[:,:CumRewTrial] = cumsum(dd.Reward)
end
gd3 = groupby(pokes,[:Protocol])
combine(gd3) do dd
    dd[:,:CumRewTrial] = dd[:,:CumRewTrial]./maximum(dd.CumRewTrial)
end
checkstim = combine(groupby(pokes,[:MouseID,:ExpDay]), :Stim => (s -> length(union(s)) > 1) => :StimDay)
checkstim[!,:StimDay] = [m in ["pc10", "pc1", "pc2", "pc3", "pc4", "pc5", "pc6", "pc7", "pc8", "pc9"] ? s : false for (m,s) in zip(checkstim.MouseID, checkstim.StimDay)]
expanded = leftjoin(pokes, checkstim, on = [:MouseID,:ExpDay]).StimDay
pokes.Stim_Day = expanded

# open_html_table(pokes[1:100,[:Side,:Poke,:Trial,:PokeIn,:PokeOut,:TimeFromLeaving]])
## Process trials dataframe
streaks = combine(groupby(pokes,[:MouseID,:Day,:Phase,:Group,:Treatment, :Injection])) do dd
        process_streaks(dd)
    end
##Process trials dataframe
count_bouts!(pokes)
bouts = combine(groupby(pokes,[:MouseID,:Day,:Phase,:Group,:Treatment, :Injection])) do dd
    process_bouts(dd)
end
##
#= Filter dataset cutting the 5th percentile tail (either bilaterally or to the right extreme)
if filtering results skewed a filter for values with a probability lower than 0.99 is applied =#

# trim_conf_ints!(pokes,:Pre_Interpoke)
# trim_conf_ints!(pokes,:PokeDuration)
#
# trim_conf_ints!(streaks,:Trial)
#= the distribution of number of pokes before leaving results bimodal;
    with early leaving seaprated from the rest. Analysis on trials
    are therefore performed with at least 2 or more pokes before leaving=#
# filter!(r-> 1< r.Num_pokes < 31, streaks)
# trim_conf_ints!(streaks, :Num_pokes; percent = 99)
# filter!(r-> r.Trial <61,streaks)
##
# @df streaks density(:Num_pokes)
# @df trim_conf_ints(streaks, :Num_pokes) density(:Num_pokes)
