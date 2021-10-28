include("filtering.jl");
using Dates
gr(size=(600,600), tick_orientation = :out, grid = false,
    linecolor = :black,
    markerstrokecolor = :black,
    thickness_scaling = 2,
    markersize = 6)
##
union(fullS.Phase)
union(fullS.Treatment)
check = combine(groupby(streaks, :Day), [:Phase, :Treatment] .=> (t -> [union(t)]))
open_html_table(check)
##
#= MVT results
    Group together None, Saline, Prevehicle and PostVehicle in one control group for this analysis
=#
check2 = filter(r-> r.Phase != "Optogenetic", streaks)
check2 = filter(r-> r.Num_pokes > 3, streaks)

df = check2
df.GroupControl = [x in ["Altanserin", "SB242084","Citalopram", "Optogenetic", "SB242084_opt", "Training"] ? x : "Controls" for x in df.Treatment]
gdcheck = groupby(df, [:GroupControl])
check3 = combine(gdcheck) do dd
    MVTprediction(dd)
end
println.(propertynames(streaks))
check3.Plot[2]
open_html_table(check3[:,1:4])
streaks.Num_pokes
##
performance = combine(groupby(streaks,[:MouseID,:Day,:Phase]), nrow)
open_html_table(performance)
##
orig = CSV.read(joinpath(files_loc,"pokes.csv"), DataFrame)
t_lim = 50
example = filter(r -> r.MouseID == "c2" && r.Day == Date(2016,03,11) && r.Trial <= t_lim, orig)
example.outcome = [x ? (y == "R" ? :green : :orange) : :lightgrey for (x,y) in zip(example.Reward,example.Side)]
example.Side
m = 10
@df example scatter(:Trial,:Poke_within_Trial, markershape = :square, markersize = 1.3, label = false, mswidth = 1, xticks = 0:10:180,
    size = (t_lim*m,20*m), markercolor = :outcome, ylims = (0,20))
##
open_html_table(example)
orig = CSV.read(joinpath(files_loc,"pokes.csv"), DataFrame)
old = CSV.read(joinpath(files_loc,"pokes_old.csv"), DataFrame)
maximum(orig.Poke_within_Trial)
maximum(old.Poke_within_Trial)

train = filter(r->r.Phase == "Citalopram", fullS)
pokes_trial = summarize(train,:Trial,:Num_pokes)
# @df pokes_trial plot(:Xaxis,:Mean, ribbon = :SEM)

Pre_Frequency = combine(groupby(train,:MouseID)) do dd
    dx = countmap(dd.Num_pokes)
    val = []
    freq = []
    for (k,v) in dx
        push!(val, k)
        push!(freq,v)
    end
    DataFrame(Val = val, Freq = freq./nrow(dd))
end

Frequency = combine(groupby(Pre_Frequency,:Val), :Freq .=> (mean,sem) .=> [:Mean, :Sem])
sort!(Frequency,:Val)
@df Frequency plot(:Val, :Mean, ribbon = :Sem)

Frequency = combine(groupby(streaks,:Treatment)) do dd
    SwitchingAnalysis.frequency(dd, :Num_pokes)
end
filter!(r -> r.Treatment in ["Altanserin", "SB242084",
    "Optogenetic", "Citalopram",
    "Control"],
    Frequency)

@df Frequency plot(:Xaxis, :Mean, group = :Treatment,ribbon = :ERR, linecolor = :auto)

Cumulative = combine(groupby(streaks,:Treatment)) do dd
    ecdf(dd, :Num_pokes)
end
filter!(r -> r.Treatment in ["Altanserin", "SB242084",
    "Optogenetic", "Citalopram",
    "Control"],
    Cumulative)
@df Cumulative plot(:Xaxis, :Mean, group = :Treatment,ribbon = :ERR, linecolor = :auto)
