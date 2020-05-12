## Script to determine values for filtering the datasets

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
## Add relevant variables

fullP[!,:Protocol] = [ismissing(x) ? missing : string(x) for x in fullP[:,:Protocol]]
dropmissing!(fullP)
gd = groupby(fullP, [:Day,:MouseID,:Trial])
transform!(gd,:Reward => Pnext => :Pnextrew)
fullP[!,:InstRewRate] = fullP.Pnextrew ./ fullP.PokeDuration

## filter basic info
pokes = filter(r-> !ismissing(r.Protocol) &&
    r.ExpDay > 5 &&
    r.Protocol in ["0.5","0.75","1.0"],
    fullP)
streaks = filter(r-> !ismissing(r.Protocol) &&
    r.ExpDay >5 &&
    r.Protocol in ["0.5","0.75","1.0"] &&
    r.Num_pokes > 1,
    fullS)

## Interpoke interval
p = trim_conf_ints(pokes,:Pre_Interpoke)
c = copy(pokes)

@df p density(:Pre_Interpoke)
k = KDensity(p[:,:Pre_Interpoke])
plot(k.x,k.density)
trim_dist(k)
quantile(p[:,:Pre_Interpoke],[0.005,0.995])

3 in 1:5
4 in 1:0.7:6
