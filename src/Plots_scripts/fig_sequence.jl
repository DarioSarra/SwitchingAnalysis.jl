using Revise
using SwitchingAnalysis
using HypothesisTests
using BrowseTables
## loading
ongoing_dir = linux_gdrive
#ongoing_dir = mac_gdrive
files_loc = joinpath(ongoing_dir,files_dir)
figs_loc = joinpath(ongoing_dir,figs_dir)
streaks =   DataFrame(CSV.read(joinpath(files_loc,"streaks.csv"); types = columns_types))
pokes =   DataFrame(CSV.read(joinpath(files_loc,"pokes.csv")))
##
union(streaks[:,:ExpDay])
gd = combine(groupby(streaks,:ExpDay)) do dd
    (day = dd[1,:Day], phase = dd[1,:Phase],
    treatment = dd[1,:Treatment], inj = dd[1,:Injection],
    PhaseDay = dd[1,:ProtocolDay])
end
open_html_table(gd)

## Adjustments

pokes[!,:Protocol] = [ismissing(x) ? missing : string(x) for x in pokes[:,:Protocol]]
filter!(r-> !ismissing(r.Protocol) &&
    r.ExpDay > 5 &&
    r.Protocol in ["0.5","0.75","1.0"] &&
    r.Trial < 60,
    pokes)

filter!(r-> !ismissing(r.Protocol) &&
    r.ExpDay >5 &&
    r.Protocol in ["0.5","0.75","1.0"] &&
    r.Trial < 60 &&
    r.Num_pokes > 1,
    streaks)
gr(size=(600,600), tick_orientation = :out, grid = false)

## Cumulative per protocol

Df = combine(groupby(streaks,:Protocol)) do dd
    ecdf(dd,:Num_pokes)
end
Protocol_colors!(Df)
@df Df plot(:Xaxis, :Mean;
    group = :Protocol,
    ribbon = :SEM,
    legend= :bottomright,
    color = :color)
savefig(joinpath(figs_loc,"CumulativePokesPerProtocol.pdf"))

## Pokes per protocol by phase

Df = combine(groupby(streaks,:Phase)) do dd
    summarize(dd,:Protocol,:Num_pokes)
end
Drug_colors!(Df)
@df Df groupedbar(:Xaxis, :Mean,
    group = :Phase,
    yerror = :SEM,
    color = :color,
    legend = false)
savefig(joinpath(figs_loc,"BarPokesPerPhase.pdf"))

## Pokes in training

control = filter(r-> r.Phase == "training", streaks)
Df = summarize(control,:Protocol,:Num_pokes)
rename!(Df,:Xaxis => :Protocol)
Protocol_colors!(Df)
sort!(Df,:Protocol)
@df Df bar(:Protocol, :Mean;
    yerror = :SEM,
    color = :color,
    yticks = 0:15,
    legend = false)
savefig(joinpath(figs_loc,"TrainingPokesPerProtocol.pdf"))

## Pokes per protocol by Treatment

Df = combine(groupby(streaks,:Treatment)) do dd
    summarize(dd,:Protocol,:Num_pokes)
end
filter!(r->!in(r.Treatment,["None","PostVehicle","Saline"]), Df)
Drug_colors!(Df)
@df Df groupedbar(:Xaxis, :Mean,
    group = :Treatment,
    yerror = :SEM,
    color = :color,
    legend = :topleft,
    ylims = (0,21))
savefig(joinpath(figs_loc,"BarPokesPerProtocolandInj.pdf"))

## PreVehicle data
control = filter(r-> r.Treatment == "PreVehicle", streaks)
Df = combine(groupby(control,:Protocol)) do dd
    ecdf(dd,:Num_pokes)
end
Protocol_colors!(Df)
@df Df plot(:Xaxis, :Mean;
    group = :Protocol,
    ribbon = :SEM,
    legend= :bottomright,
    color = :color)
savefig(joinpath(figs_loc,"CumulativePreVeh.pdf"))
Df = summarize(control,:Protocol,:Num_pokes)
rename!(Df,:Xaxis => :Protocol)
Protocol_colors!(Df)
sort!(Df,:Protocol)
@df Df bar(:Protocol, :Mean;
    yerror = :SEM,
    color = :color,
    yticks = 0:15,
    legend = false)
savefig(joinpath(figs_loc,"PreVehPokesPerProtocol.pdf"))



## Preward at leaving

streaks
