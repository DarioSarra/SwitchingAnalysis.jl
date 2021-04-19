include("filtering.jl");
gr(markerstrokecolor = :black,markersize = 8,)
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
    r.Trial < 51 &&
    # r.Trial_Travel_to < 40 &&
    r.MouseID != "pc7",
    streaks)
b = filter(r->r.Treatment in list &&
    r.Trial < 51 &&
    # r.Trial_Travel_to < 40 &&
    r.MouseID != "pc7",
    bouts)
p = copy(pokes)
for df in [s,b, p]
    df[df.Treatment .== "PreVehicle",:Treatment] .= "Control"
    df[df.Treatment .== "Saline",:Treatment] = [o ? "Optogenetic" : "Control" for o in df[df.Treatment .== "Saline",:Stim]]
    df[df.Treatment .== "SB242084_opt",:Phase] .=  "SB242084_opt"
    df[df.Treatment .== "SB242084_opt",:Treatment] = [o ? "SB242084_opt" : "Control" for o in df[df.Treatment .== "SB242084_opt",:Stim]]
end
##
#look at survival function without censor data. That is looking only at last bout in a trial, not bout interrupted by a reward
f_bouts = filter(r-> r.Omissions_plus_one >= 2 &&
    r.Leave &&
    r.Treatment in ["Control", "Citalopram", "Optogenetic", "SB242084", "Altanserin"],
    b)
f_bouts.BoutOut
f_bouts.Bout_duration
res, plt = mediansurvival_analysis(f_bouts,:Bout_duration,:Treatment)
Drug_colors!(res)
plt = @df res scatter(string.(:Treatment), :Mean, yerror = :Sem, color = :color,
    xlabel = "Group", ylabel = "Median survival time", label = "")
savefig(joinpath(figs_loc,"ForagingMeeting/mediansurvival.pdf"))

f_res = function_analysis(f_bouts,:Bout_duration, survivalrate_algorythm; grouping = :Treatment, step =0.05)
Drug_colors!(f_res)
@df f_res plot(:Bout_duration,:Mean, ribbon = :Sem, group = :Treatment,
    color = :color, linecolor = :color, xlims = (0,20),
    xlabel = "Consecutive unrewarded poking time", ylabel = "Survival rate")
savefig(joinpath(figs_loc,"ForagingMeeting/SurvivalRate.pdf"))
##
b2 = filter(r -> r.Treatment in ["Control", "Citalopram", "Optogenetic", "SB242084", "Altanserin"], b)
KMdf = combine(groupby(b2,[:MouseID,:Treatment]), [:Bout_duration, :Leave] => ((d,l) -> fit(KaplanMeier,d,l)) => :KMfit)
transform!(KMdf, :KMfit => ByRow(SwitchingAnalysis.KM_median) => :KM_median)
dropmissing!(KMdf)
res2 = combine(groupby(KMdf, :Treatment), :KM_median .=> [mean, sem])
Drug_colors!(res2)
plt = @df res2 scatter(string.(:Treatment), :KM_median_mean, yerror = :KM_median_sem, color = :color,
    xlabel = "Group", ylabel = "Median Kaplan Meier survival time", label = "")
savefig(joinpath(figs_loc,"ForagingMeeting/KMmediansurvival.pdf"))

survdf = survival_analysis(b2,:Bout_duration, :Leave; grouping = :Treatment, step =0.05)
Drug_colors!(survdf)
@df survdf plot(:Bout_duration, :Mean, ribbon = :Sem, group = :Treatment,
    color = :color, linecolor = :color, xlims = (0,10),
    xlabel = "Consecutive unrewarded poking time", ylabel = "Survival rate")
savefig(joinpath(figs_loc,"ForagingMeeting/KMSurvivalRate.pdf"))
##
f_pokes = filter(r -> r.Treatment in ["Control", "Citalopram", "Optogenetic", "SB242084", "Altanserin"], p)
f_pokes.Treatment = categorical(f_pokes.Treatment)
levels!(f_pokes.Treatment,["Control", "Citalopram", "Optogenetic", "SB242084", "Altanserin"])
gd = groupby(f_pokes, [:MouseID, :Day, :Treatment, :Bout])
res3 = combine(gd, [:PokeIn, :PokeOut] => ((i,o) -> (In_bout = i .- first(i), Out_bout = o .- first(i))) => AsTable,
    :LastPoke => :Leave,
    :Protocol)
transform!(res3, :Out_bout => zscore)
verbBasic = @formula(Leave ~ 1 + Out_bout_zscore * Protocol +  (1+Out_bout_zscore+Protocol|MouseID));
LeaveBasic = fit(MixedModel,verbBasic, res3, Bernoulli())

verbSimpleBasic = @formula(Leave ~ 1 + Out_bout_zscore + Protocol +  (1+Out_bout_zscore+Protocol|MouseID));
LeaveSimpleBasic = fit(MixedModel,verbSimpleBasic, res3, Bernoulli())

SimpleFullBasicTest = MixedModels.likelihoodratiotest(LeaveSimpleBasic,LeaveBasic)

verbTreatment = @formula(Leave ~ 1 + Out_bout_zscore * Treatment + Protocol * Treatment +  (1+Out_bout_zscore+Protocol|MouseID));
LeaveTreatment = fit(MixedModel,verbTreatment, res3, Bernoulli())

TreatmentTest = MixedModels.likelihoodratiotest(LeaveSimpleBasic,LeaveTreatment)
