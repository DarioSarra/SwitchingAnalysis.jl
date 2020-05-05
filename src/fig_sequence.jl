using Revise
using SwitchingAnalysis

# loading
streaks =  CSV.read(joinpath(files_dir,"streaks.csv"); types = columns_types) |> DataFrame
pokes =  CSV.read(joinpath(files_dir,"pokes.csv")) |> DataFrame
##
filter!(r-> !ismissing(r.Protocol) &&
    r.Protocol in ["0.5","0.75","1.0"],
    streaks)
## Reward per protocol
gr(size=(600,600), tick_orientation = :out, grid = false)
Df = by(streaks,:Phase) do dd
    summarize(dd,:Protocol,:Num_Rewards)
end
Df.color = [get(drug_colors,x,RGB(0,0,0)) for x in Df.Phase]
@df Df groupedbar(:Xaxis, :Mean,
    group = :Phase,
    yerror = :SEM,
    color = :color,
    legend = :topleft)
savefig(joinpath(figs_dir,"RewardsPerProtocol.pdf"))

## Protocols Decay

Df = Prew(1:20)
Protocol_colors!(Df)
@df Df plot(:Poke, :Prew,
    group = :env, color = :color)
@df Df scatter!(:Poke, :Prew,
    group = :env, color = :color)
savefig(joinpath(figs_dir,"ProtocolsDecay.pdf"))
## Pokes per trial

Df = by(streaks,:Protocol) do dd
    ecdf(dd,:Num_pokes)
end
Protocol_colors!(Df)
@df Df plot(:Xaxis, :Mean;
    group = :Protocol,
    ribbon = :SEM,
    legend= :bottomright,
    color = :color)
savefig(joinpath(figs_dir,"PokesPerTrial.pdf"))
##
