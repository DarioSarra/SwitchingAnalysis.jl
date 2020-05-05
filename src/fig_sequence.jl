using Revise
using SwitchingAnalysis

# loading
streaks =  CSV.read(joinpath(files_dir,"streaks.csv"); types = columns_types) |> DataFrame
pokes =  CSV.read(joinpath(files_dir,"pokes.csv")) |> DataFrame
##
filter!(r-> !ismissing(r.Protocol) &&
    r.Protocol in ["0.5","0.75","1.0"],
    streaks)
## Reward per trial
gr(size=(600,600))
Df = by(streaks,:Phase) do dd
    prepare_df(dd,:Protocol,:Num_Rewards)
end
plot(rand(10))
Df.color = get.(color_dict,Df.Phase,RGB(0,0,0))
@df Df groupedbar(:Xaxis, :Mean,
    group = :Phase,
    yerror = :SEM,
    color_palette = palette([:purple, :green], 6))

##
Df = Prew(1:20)
@df Df scatter(:Poke, :Prew,
    group = :Protocol)
##
with_err = prepare_df(streaks,:Num_pokes,ecdf)
@df with_err plot(:Xaxis, :Mean;
    ribbon = :SEM)
##
