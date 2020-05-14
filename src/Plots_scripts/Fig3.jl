include("filtering.jl");
## number of pokes before leaving
list = ["PreVehicle",
    "Altanserin",
    "SB242084",
    "Way_100135",
    "Methysergide",
    "Citalopram"]
s = filter(r->r.Treatment in list &&
    r.Trial < 61,
    streaks)
Df = combine(groupby(s,[:Phase,:Treatment])) do dd
    ecdf(dd,:Num_pokes;mode = :conf_int)
end
confint(OneSampleTTest(streaks[:,:Num_pokes]))
mean(streaks[:,:Num_pokes])
Drug_colors!(Df)
gd = groupby(Df,:Phase)
tp = [@df subdf plot(:Xaxis, :Mean,
    xlabel = :Phase[1],
    xticks = 0:2:20,
    group = :Treatment,
    color = :color,
    legend = false,
    ribbon = :SEM) for subdf in gd]
ord = [5,3,4,2,1]
plot(tp[ord]...)
