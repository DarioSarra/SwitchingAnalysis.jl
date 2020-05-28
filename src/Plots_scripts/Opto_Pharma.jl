include("filtering.jl");
##
list = ["PreVehicle",
    "Altanserin",
    "SB242084",
    "Way_100135",
    "Methysergide",
    "Citalopram",
    "SB242084_opt",
    "Saline"]
s = filter(r->r.Treatment in list &&
    r.Trial < 61 &&
    # r.Trial_Travel_to < 10 &&
    r.MouseID in ["pc1","pc2","pc3","pc4","pc5","pc6","pc8","pc9","pc10"],
    streaks)
GroupC_PreVehicle = [Date(2016,07,22),Date(2016,07,27), Date(2016,07,31)]
GroupD_PreVehicle = [Date(2016,07,21),Date(2016,07,25), Date(2016,07,29)]
s[:,:Treatment] = [r.Group == "Group C" && r.Day in GroupC_PreVehicle ? "Control" : r.Treatment for r in eachrow(s)]
s[:,:Treatment] = [r.Group == "Group D" && r.Day in GroupD_PreVehicle ? "Control" : r.Treatment for r in eachrow(s)]
##
optopharma = filter(r ->
    r.Treatment in ["Control", "SB242084_opt"], s)
gd = groupby(optopharma,[:MouseID,:Treatment,:Stim])
df1 = combine([:Num_pokes,:AfterLast,:Trial_Travel_to] => (n,a,t) ->
    (Num_pokes = mean(n), AfterLast = mean(a), Travel = mean(t))
    ,gd)
# select the variable to analyze
df2 = select(df1, Not([:Travel,:Num_pokes]))
df3 = combine(groupby(df2,:Stim)) do dd
    subdf = unstack(dd,:Treatment,:AfterLast)
    # current_drug = Symbol(subdf[1,:Phase])
    # rename!(subdf, current_drug => :Drug)
end
df4 = combine(groupby(df3,[:Stim])) do dd
    wilcoxon(dd,:SB242084_opt, :Control; f = x -> mean(skipmissing(x)))
end
plot_wilcoxon(df4)

open_html_table(df3)
disallowmissing!(df3)
SignedRankTest(df3[df3.Stim,:SB242084_opt],df3[df3.Stim,:Control])
SignedRankTest(df3[.!(df3.Stim),:SB242084_opt],df3[.!(df3.Stim),:Control])
