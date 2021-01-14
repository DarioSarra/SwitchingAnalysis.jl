include("filtering.jl");
gr(size=(600,600), tick_orientation = :out, grid = false,
    linecolor = :black,
    markerstrokecolor = :black,
    thickness_scaling = 2,
    markersize = 6)
################################ Adjust Streaks table ##################################
list = ["PreVehicle",
    "Altanserin",
    "SB242084",
    "Way_100135",
    "Methysergide",
    "Citalopram",
    "SB242084_opt",
    "Saline"]
filter!(r->r.Treatment in list &&
    r.Trial < 51 &&
    r.MouseID != "pc7",
    streaks)

streaks[streaks.Treatment .== "PreVehicle",:Treatment] .= "Control"
streaks[streaks.Treatment .== "Saline",:Treatment] = [o ? "Optogenetic" : "Control" for o in streaks[streaks.Treatment .== "Saline",:Stim]]
streaks[streaks.Treatment .== "SB242084_opt",:Phase] .=  "SB242084_opt"
streaks[streaks.Treatment .== "SB242084_opt",:Treatment] = [o ? "SB242084_opt" : "Control" for o in streaks[streaks.Treatment .== "SB242084_opt",:Stim]]
streaks[!,:ROILeavingTime] = streaks.Stop_trial .- streaks.Stop_poking
streaks[!,:Treatment] = categorical(streaks.Treatment, ordered = false)
levels!(streaks.Treatment,["Control",
    "Altanserin",
    "SB242084",
    "Way_100135",
    "Citalopram",
    "Optogenetic",
    "Methysergide",
    "SB242084_opt"
    ])
levels(streaks.Treatment)
################################ Adjust Pokes table ##################################
filter!(r->r.Treatment in list &&
    r.Trial < 51 &&
    r.MouseID != "pc7",
    pokes)
pokes[pokes.Treatment .== "PreVehicle",:Treatment] .= "Control"
pokes[pokes.Treatment .== "Saline",:Treatment] = [o ? "Optogenetic" : "Control" for o in pokes[pokes.Treatment .== "Saline",:Stim]]
pokes[pokes.Treatment .== "SB242084_opt",:Phase] .=  "SB242084_opt"
pokes[pokes.Treatment .== "SB242084_opt",:Treatment] = [o ? "SB242084_opt" : "Control" for o in pokes[pokes.Treatment .== "SB242084_opt",:Stim]]


filt_1 = filter(r->r.Treatment == "Control",pokes)
gd1 = groupby(filt_1,[:MouseID,:TimeFromLeaving,:Protocol])
df2 = combine(gd1, :CumRewTrial => mean => :CumRewTrial)
gd2 = groupby(df2,[:Protocol,:TimeFromLeaving])
df3 = combine(gd2, :CumRewTrial => mean, :CumRewTrial => sem)
Protocol_colors!(df3)

@df df3 scatter(:TimeFromLeaving,:CumRewTrial_mean, group = :Protocol, xlims = (0,30), markersize = 4, color = :color)

################################ Fig2 scatter  controls ##################################
Pstate= Prew(1:20)
open_html_table(Pstate)
Pstate[!,:Color] = [get(protocol_colors,x,:grey) for x in Pstate.Protocol]
@df Pstate plot(:Poke,:Prew, group = :Protocol, linecolor = :Color, legend = false)
@df Pstate scatter!(:Poke,:Prew, group = :Protocol, color = :Color, ylims = (0,1.1), yticks = 0:0.2:1)
savefig(joinpath(figs_loc,"LabMeetingJan2021","Fig2","Distributions.pdf"))

gd1 = groupby(streaks,[:Protocol,:MouseID,:Phase,:Treatment])
df1 = combine(gd1, :Num_Rewards => mean => :Num_Rewards,
    :Num_pokes => mean => :Num_pokes,
    :AfterLast => mean => :AfterLast,
    :Leaving_NextPrew => mean => :Leaving_NextPrew,
    :AverageRewRate => mean => :AverageRewRate)

gd2 = groupby(df1,:Treatment)
df2 = combine(gd2, :AverageRewRate => mean, :AverageRewRate => sem,
    :Leaving_NextPrew => mean, :Leaving_NextPrew => sem)
filt_2 = filter(r->r.Treatment == "Control",df2)
res = DataFrame(Condition = ["Average", "At Leaving"],
    Mean = [filt_2[1,:AverageRewRate_mean], filt_2[1,:Leaving_NextPrew_mean]],
    Sem = [filt_2[1,:AverageRewRate_sem], filt_2[1,:Leaving_NextPrew_sem]])
@df res scatter(:Condition,:Mean, yerror = :Sem, color = :grey, xlims = (0.25,1.75), label = false,ylims = (0.1,0.3), yticks = 0.0:0.1:0.3)
savefig(joinpath(figs_loc,"LabMeetingJan2021","Fig2","RateAtLeaving.pdf"))


gd3 = groupby(df1,[:Protocol,:Treatment])
df3 = combine(gd3, :Num_Rewards => mean, :Num_Rewards => sem,
    :Num_pokes => mean, :Num_pokes => sem,
    :AfterLast => mean, :AfterLast => sem,
    :Leaving_NextPrew => mean, :Leaving_NextPrew => sem)

filt_3 = filter(r->r.Treatment == "Control",df3)
sort!(filt_3, :Protocol)
filt_3[!,:Color] = [get(protocol_colors,x,:grey) for x in filt_3.Protocol]
@df filt_3 scatter(:Protocol, :Num_Rewards_mean, yerror = :Num_Rewards_sem, label = false, color = :Color, xlims = (0.25,2.75), ylims = (1,5), yticks = 0:0.5:10)
savefig(joinpath(figs_loc,"LabMeetingJan2021","Fig2","NumRewards.pdf"))
@df filt_3 scatter(:Protocol, :Num_pokes_mean, yerror = :Num_pokes_sem, label = false, color = :Color, xlims = (0.25,2.75), ylims = (11,15))
savefig(joinpath(figs_loc,"LabMeetingJan2021","Fig2","NumPokes.pdf"))
@df filt_3 scatter(:Protocol, :AfterLast_mean, yerror = :AfterLast_sem, label = false, color = :Color, xlims = (0.25,2.75), ylims = (5,7))
savefig(joinpath(figs_loc,"LabMeetingJan2021","Fig2","AfterLast.pdf"))
@df filt_3 scatter(:Protocol, :Leaving_NextPrew_mean, yerror = :Leaving_NextPrew_sem,label = false, color = :Color, xlims = (0.25,2.75), ylims = (0.1,0.3), yticks = 0.0:0.1:0.3)
savefig(joinpath(figs_loc,"LabMeetingJan2021","Fig2","Prew.pdf"))


testdf = filter(r->r.Treatment == "Control",streaks)
testdf[!,:NumericalProt] = parse.(Float64, testdf.Protocol)
NR_m1 = fit!(LinearMixedModel(@formula(Num_Rewards ~ 1 + (1|MouseID)),testdf))
NR_m2 = fit!(LinearMixedModel(@formula(Num_Rewards ~ 1 + NumericalProt + (1|MouseID)),testdf))
Likelyhood_Ratio_test(NR_m1,NR_m2)
NP_m1 = fit!(LinearMixedModel(@formula(Num_pokes ~ 1 + (1|MouseID)),testdf))
NP_m2 = fit!(LinearMixedModel(@formula(Num_pokes ~ 1 + NumericalProt + (1|MouseID)),testdf))
Likelyhood_Ratio_test(NP_m1,NP_m2)
AL_m1 = fit!(LinearMixedModel(@formula(AfterLast ~ 1 + (1|MouseID)),testdf))
AL_m2 = fit!(LinearMixedModel(@formula(AfterLast ~ 1 + NumericalProt + (1|MouseID)),testdf))
Likelyhood_Ratio_test(AL_m1,AL_m2)
PR_m1 = fit!(LinearMixedModel(@formula(Leaving_NextPrew ~ 1 + (1|MouseID)),testdf))
PR_m2 = fit!(LinearMixedModel(@formula(Leaving_NextPrew ~ 1 + NumericalProt + (1|MouseID)),testdf))
Likelyhood_Ratio_test(PR_m1,PR_m2)

# fm4 = fit(MixedModel,@formula(AfterLast ~ 1 + (1|MouseID)),age_df,Poisson())
################################ Fig3 selective protocol effect ##################################
df1 = combine(groupby(streaks,:Phase)) do dd
    subdf = unstack(dd,:Treatment,:ROI_Leaving_Time)
    current_drug = Symbol(subdf[1,:Phase])
    rename!(subdf, current_drug => :Drug)
end

df2 = combine(groupby(df1,[:Phase])) do dd
    wilcoxon(dd,:Control, :Drug; f = x -> mean(skipmissing(x)))
end
Drug_colors!(df2)
plot_wilcoxon(filter!(r->r.Phase in ["SB242084","Altanserin"],df2),showmice = false)
savefig(joinpath(figs_loc,"LabMeetingJan2021","Fig3","Sel_Wilcoxon_ROILeaving.pdf"))

df2 = combine(groupby(df1,[:Protocol,:Phase])) do dd
    wilcoxon(dd,:Control, :Drug; f = x -> mean(skipmissing(x)))
end
Drug_colors!(df2)
plot_wilcoxon(filter!(r->r.Phase in ["SB242084","Altanserin"],df2),showmice = false)
################################ Fig3 scatter  selective ##################################
gd1 = groupby(streaks,[:Protocol,:MouseID,:Phase,:Treatment])
df1 = combine(gd1, :Num_Rewards => mean => :Num_Rewards,
    :Num_pokes => mean => :Num_pokes,
    :AfterLast => mean => :AfterLast,
    :Leaving_NextPrew => mean => :Leaving_NextPrew,
    :AverageRewRate => mean => :AverageRewRate)

gd2 = groupby(df1,[:Protocol,:Treatment])

df2 = combine(gd2, [:Num_Rewards,:Num_pokes,:AfterLast,:Leaving_NextPrew,:AverageRewRate] .=> mean,
    [:Num_Rewards,:Num_pokes,:AfterLast,:Leaving_NextPrew,:AverageRewRate] .=> sem,
    [:Num_Rewards,:Num_pokes,:AfterLast,:Leaving_NextPrew,:AverageRewRate] .=> median,
    [:Num_Rewards,:Num_pokes,:AfterLast,:Leaving_NextPrew,:AverageRewRate] .=> CIq
    )

dp = filter!(r->r.Treatment in ["SB242084","Altanserin", "Control"],df2)
Drug_colors!(dp)
@df dp scatter(:Protocol, :Num_Rewards_mean, yerror = :Num_Rewards_sem, group = :Treatment, color = :color, xflip = true, yticks = 1:0.5:6, xlims = (0.25,2.75), label = false)
@df dp scatter(:Protocol, :Num_Rewards_median, yerror = :Num_Rewards_CIq, group = :Treatment, color = :color, xflip = true, yticks = 1:0.5:6, xlims = (0.25,2.75), label = false)
savefig(joinpath(figs_loc,"LabMeetingJan2021","Fig3","Sel_Prot_NumRewards.pdf"))

@df dp scatter(:Protocol, :Num_pokes_mean, yerror = :Num_pokes_sem, group = :Treatment, color = :color, xflip = true, yticks = 8:1:17, xlims = (0.25,2.75), label = false)
@df dp scatter(:Protocol, :Num_pokes_median, yerror = :Num_pokes_CIq, group = :Treatment, color = :color, xflip = true, yticks = 8:1:17, xlims = (0.25,2.75), label = false)
savefig(joinpath(figs_loc,"LabMeetingJan2021","Fig3","Sel_Prot_NumPokes.pdf"))

@df dp scatter(:Protocol, :AfterLast_mean, yerror = :AfterLast_sem, group = :Treatment, color = :color, xflip = true, yticks = 4:0.5:10, xlims = (0.25,2.75), label = false)
@df dp scatter(:Protocol, :AfterLast_median, yerror = :AfterLast_CIq, group = :Treatment, color = :color, xflip = true, yticks = 4:0.5:10, xlims = (0.25,2.75), label = false)
savefig(joinpath(figs_loc,"LabMeetingJan2021","Fig3","Sel_Prot_AfterLast.pdf"))

@df dp scatter(:Protocol, :Leaving_NextPrew_mean, yerror = :Leaving_NextPrew_sem, group = :Treatment, color = :color, xflip = true, yticks = 0.1:0.1:0.5, ylims = (0.1,0.5), xlims = (0.25,2.75), label = false)
@df dp scatter(:Protocol, :Leaving_NextPrew_median, yerror = :Leaving_NextPrew_CIq, group = :Treatment, color = :color, xflip = true, yticks = 0.1:0.1:0.5, ylims = (0.1,0.5), xlims = (0.25,2.75), label = false)
savefig(joinpath(figs_loc,"LabMeetingJan2021","Fig3","Sel_Prot_PrewLeaving.pdf"))
################################ Fig4 global protocol effect ##################################
df1 = combine(groupby(streaks,:Phase)) do dd
    subdf = unstack(dd,:Treatment,:Num_Rewards)
    current_drug = Symbol(subdf[1,:Phase])
    rename!(subdf, current_drug => :Drug)
end

df2 = combine(groupby(df1,[:Phase])) do dd
    wilcoxon(dd,:Control, :Drug; f = x -> mean(skipmissing(x)))
end
Drug_colors!(df2)
plot_wilcoxon(filter!(r->r.Phase in ["Optogenetic","Citalopram"],df2),showmice = false)
plot_wilcoxon(filter!(r->r.Phase in ["Optogenetic","Citalopram"],df2),showmice = false)
savefig(joinpath(figs_loc,"LabMeetingJan2021","Fig4","Glob_Wilcoxon_ROILeaving.pdf"))


streaks.Poking_Travel_to
streaks.Trial_Travel_to
streaks.ROI_Leaving_Time

df2 = combine(groupby(df1,[:Protocol,:Phase])) do dd
    wilcoxon(dd,:Control, :Drug; f = x -> mean(skipmissing(x)))
end
Drug_colors!(df2)
plot_wilcoxon(filter!(r->r.Phase in ["Optogenetic","Citalopram"],df2),showmice = false)
################################ Fig4 scatter  global ##################################
gd1 = groupby(streaks,[:Protocol,:MouseID,:Phase,:Treatment])
df1 = combine(gd1, :Num_Rewards => mean => :Num_Rewards,
    :Num_pokes => mean => :Num_pokes,
    :AfterLast => mean => :AfterLast,
    :Leaving_NextPrew => mean => :Leaving_NextPrew,
    :AverageRewRate => mean => :AverageRewRate)

gd2 = groupby(df1,[:Protocol,:Treatment])

df2 = combine(gd2, [:Num_Rewards,:Num_pokes,:AfterLast,:Leaving_NextPrew,:AverageRewRate] .=> mean,
    [:Num_Rewards,:Num_pokes,:AfterLast,:Leaving_NextPrew,:AverageRewRate] .=> sem,
    [:Num_Rewards,:Num_pokes,:AfterLast,:Leaving_NextPrew,:AverageRewRate] .=> median,
    [:Num_Rewards,:Num_pokes,:AfterLast,:Leaving_NextPrew,:AverageRewRate] .=> CIq
    )

dp = filter!(r->r.Treatment in ["Optogenetic","Citalopram","Control"],df2)
Drug_colors!(dp)
@df dp scatter(:Protocol, :Num_Rewards_mean, yerror = :Num_Rewards_sem, group = :Treatment, color = :color, xflip = true, yticks = 1:0.5:6, xlims = (0.25,2.75), label = false)
@df dp scatter(:Protocol, :Num_Rewards_median, yerror = :Num_Rewards_CIq, group = :Treatment, color = :color, xflip = true, yticks = 1:0.5:6, xlims = (0.25,2.75), label = false)
savefig(joinpath(figs_loc,"LabMeetingJan2021","Fig4","Glob_Prot_NumRewards.pdf"))

@df dp scatter(:Protocol, :Num_pokes_mean, yerror = :Num_pokes_sem, group = :Treatment, color = :color, xflip = true, yticks = 8:1:17, xlims = (0.25,2.75), label = false)
@df dp scatter(:Protocol, :Num_pokes_median, yerror = :Num_pokes_CIq, group = :Treatment, color = :color, xflip = true, yticks = 8:1:17, xlims = (0.25,2.75), label = false)
savefig(joinpath(figs_loc,"LabMeetingJan2021","Fig4","Glob_Prot_NumPokes.pdf"))

@df dp scatter(:Protocol, :AfterLast_mean, yerror = :AfterLast_sem, group = :Treatment, color = :color, xflip = true, yticks = 4:0.5:10, xlims = (0.25,2.75), label = false)
@df dp scatter(:Protocol, :AfterLast_median, yerror = :AfterLast_CIq, group = :Treatment, color = :color, xflip = true, yticks = 4:0.5:10, xlims = (0.25,2.75), label = false)
savefig(joinpath(figs_loc,"LabMeetingJan2021","Fig4","Glob_Prot_AfterLast.pdf"))

@df dp scatter(:Protocol, :Leaving_NextPrew_mean, yerror = :Leaving_NextPrew_sem, group = :Treatment, color = :color, xflip = true, yticks = 0.1:0.1:0.6, ylims = (0.1,0.6), xlims = (0.25,2.75), label = false)
@df dp scatter(:Protocol, :Leaving_NextPrew_median, yerror = :Leaving_NextPrew_CIq, group = :Treatment, color = :color, xflip = true, yticks = 0.1:0.1:0.5, ylims = (0.1,0.5), xlims = (0.25,2.75), label = false)
savefig(joinpath(figs_loc,"LabMeetingJan2021","Fig4","Glob_Prot_PrewLeaving.pdf"))
################################### Selective Stats #####################################
test_SEL = filter(r->r.Phase in ["SB242084", "Altanserin"],streaks)
test_SEL[!,:NumericalProt] = parse.(Float64, test_Sel.Protocol)

NR_SEL_m1 = fit!(LinearMixedModel(@formula(Num_Rewards ~ 1 + (1|MouseID)),test_SEL))
NR_SEL_m2 = fit!(LinearMixedModel(@formula(Num_Rewards ~ 1 + NumericalProt + (1|MouseID)),test_SEL))
NR_SEL_m3 = fit!(LinearMixedModel(@formula(Num_Rewards ~ 1 + Treatment + NumericalProt + (1|MouseID)),test_SEL))
Likelyhood_Ratio_test(NR_SEL_m1,NR_SEL_m2)
Likelyhood_Ratio_test(NR_SEL_m2,NR_SEL_m3)


NP_SEL_m1 = fit!(LinearMixedModel(@formula(Num_pokes ~ 1 + (1|MouseID)),test_SEL))
NP_SEL_m2 = fit!(LinearMixedModel(@formula(Num_pokes ~ 1 + NumericalProt + (1|MouseID)),test_SEL))
NP_SEL_m3 = fit!(LinearMixedModel(@formula(Num_pokes ~ 1 + NumericalProt + Treatment + (1|MouseID)),test_SEL))
Likelyhood_Ratio_test(NP_SEL_m1,NP_SEL_m2)
Likelyhood_Ratio_test(NP_SEL_m2,NP_SEL_m3)

AL_SEL_m1 = fit!(LinearMixedModel(@formula(AfterLast ~ 1 + (1|MouseID)),test_SEL))
AL_SEL_m2 = fit!(LinearMixedModel(@formula(AfterLast ~ 1 + NumericalProt + (1|MouseID)),test_SEL))
AL_SEL_m3 = fit!(LinearMixedModel(@formula(AfterLast ~ 1 + NumericalProt + Treatment + (1|MouseID)),test_SEL))
AL_SEL_m4 = fit!(LinearMixedModel(@formula(AfterLast ~ 1 + NumericalProt * Treatment + (1|MouseID)),test_SEL))
Likelyhood_Ratio_test(AL_SEL_m1,AL_SEL_m2)
Likelyhood_Ratio_test(AL_SEL_m2,AL_SEL_m3)
Likelyhood_Ratio_test(AL_SEL_m3,AL_SEL_m4)

PR_SEL_m1 = fit!(LinearMixedModel(@formula(Leaving_NextPrew ~ 1 + (1|MouseID)),test_SEL))
PR_SEL_m2 = fit!(LinearMixedModel(@formula(Leaving_NextPrew ~ 1 + NumericalProt + (1|MouseID)),test_SEL))
PR_SEL_m3 = fit!(LinearMixedModel(@formula(Leaving_NextPrew ~ 1 + NumericalProt + Treatment + (1|MouseID)),test_SEL))
PR_SEL_m4 = fit!(LinearMixedModel(@formula(Leaving_NextPrew ~ 1 + NumericalProt * Treatment + (1|MouseID)),test_SEL))
Likelyhood_Ratio_test(PR_SEL_m1,PR_SEL_m2)
Likelyhood_Ratio_test(PR_SEL_m2,PR_SEL_m3)
Likelyhood_Ratio_test(PR_SEL_m3,PR_SEL_m4)
############################### Global stats #################################
test_GLO = filter(r->r.Phase in ["Optogenetic", "Citalopram"],streaks)
test_GLO[!,:NumericalProt] = parse.(Float64, test_GLO.Protocol)

NR_GLO_m1 = fit!(LinearMixedModel(@formula(Num_Rewards ~ 1 + (1|MouseID)),test_GLO))
NR_GLO_m2 = fit!(LinearMixedModel(@formula(Num_Rewards ~ 1 + NumericalProt + (1|MouseID)),test_GLO))
NR_GLO_m3 = fit!(LinearMixedModel(@formula(Num_Rewards ~ 1 + Treatment + NumericalProt + (1|MouseID)),test_GLO))
NR_GLO_m4 = fit!(LinearMixedModel(@formula(Num_Rewards ~ 1 + Treatment * NumericalProt + (1|MouseID)),test_GLO))
Likelyhood_Ratio_test(NR_GLO_m1,NR_GLO_m2)
Likelyhood_Ratio_test(NR_GLO_m2,NR_GLO_m3)
Likelyhood_Ratio_test(NR_GLO_m3,NR_GLO_m4)

NP_GLO_m1 = fit!(LinearMixedModel(@formula(Num_pokes ~ 1 + (1|MouseID)),test_GLO))
NP_GLO_m2 = fit!(LinearMixedModel(@formula(Num_pokes ~ 1 + NumericalProt + (1|MouseID)),test_GLO))
NP_GLO_m3 = fit!(LinearMixedModel(@formula(Num_pokes ~ 1 + NumericalProt + Treatment + (1|MouseID)),test_GLO))
NP_GLO_m4 = fit!(LinearMixedModel(@formula(Num_pokes ~ 1 + NumericalProt * Treatment + (1|MouseID)),test_GLO))
Likelyhood_Ratio_test(NP_GLO_m1,NP_GLO_m2)
Likelyhood_Ratio_test(NP_GLO_m2,NP_GLO_m3)
Likelyhood_Ratio_test(NP_GLO_m3,NP_GLO_m4)


AL_GLO_m1 = fit!(LinearMixedModel(@formula(AfterLast ~ 1 + (1|MouseID)),test_GLO))
AL_GLO_m2 = fit!(LinearMixedModel(@formula(AfterLast ~ 1 + NumericalProt + (1|MouseID)),test_GLO))
AL_GLO_m3 = fit!(LinearMixedModel(@formula(AfterLast ~ 1 + NumericalProt + Treatment + (1|MouseID)),test_GLO))
AL_GLO_m4 = fit!(LinearMixedModel(@formula(AfterLast ~ 1 + NumericalProt * Treatment + (1|MouseID)),test_GLO))
Likelyhood_Ratio_test(AL_GLO_m1,AL_GLO_m2)
Likelyhood_Ratio_test(AL_GLO_m2,AL_GLO_m3)
Likelyhood_Ratio_test(AL_GLO_m3,AL_GLO_m4)


PR_GLO_m1 = fit!(LinearMixedModel(@formula(Leaving_NextPrew ~ 1 + (1|MouseID)),test_GLO))
PR_GLO_m2 = fit!(LinearMixedModel(@formula(Leaving_NextPrew ~ 1 + NumericalProt + (1|MouseID)),test_GLO))
PR_GLO_m3 = fit!(LinearMixedModel(@formula(Leaving_NextPrew ~ 1 + NumericalProt + Treatment + (1|MouseID)),test_GLO))
PR_GLO_m4 = fit!(LinearMixedModel(@formula(Leaving_NextPrew ~ 1 + NumericalProt * Treatment + (1|MouseID)),test_GLO))
Likelyhood_Ratio_test(PR_GLO_m1,PR_GLO_m2)
Likelyhood_Ratio_test(PR_GLO_m2,PR_GLO_m3)
Likelyhood_Ratio_test(PR_GLO_m3,PR_GLO_m4)

################################ Fig3 test selective ##################################
s = filter(r -> r.Phase in ["Altanserin", "SB242084","Way_100135"], streaks)
df1 = combine(groupby(s,:Phase)) do dd
    subdf = unstack(dd,:Treatment,:Num_pokes)
    current_drug = Symbol(subdf[1,:Phase])
    rename!(subdf, current_drug => :Drug)
end
df2 = combine(groupby(df1,[:Phase])) do dd
    wilcoxon(dd,:Control, :Drug; f = x -> mean(skipmissing(x)))
end
Drug_colors!(df2)
plot_wilcoxon(df2; sorting = Plotting_position)
savefig(joinpath(figs_loc,"LabMeetingJan2021","Fig3","Sel_test_Numpokes.pdf"))

df1 = combine(groupby(s,:Phase)) do dd
    subdf = unstack(dd,:Treatment,:AfterLast)
    current_drug = Symbol(subdf[1,:Phase])
    rename!(subdf, current_drug => :Drug)
end
df2 = combine(groupby(df1,[:Phase])) do dd
    wilcoxon(dd,:Control, :Drug; f = x -> mean(skipmissing(x)))
end
Drug_colors!(df2)
plot_wilcoxon(df2; sorting = Plotting_position)
savefig(joinpath(figs_loc,"LabMeetingJan2021","Fig3","Sel_test_AfterLast.pdf"))

df1 = combine(groupby(s,:Phase)) do dd
    subdf = unstack(dd,:Treatment,:Poking_Travel_to)
    current_drug = Symbol(subdf[1,:Phase])
    rename!(subdf, current_drug => :Drug)
end
df2 = combine(groupby(df1,[:Phase])) do dd
    wilcoxon(dd,:Control, :Drug; f = x -> mean(skipmissing(x)))
end
Drug_colors!(df2)
plot_wilcoxon(df2; sorting = Plotting_position)
savefig(joinpath(figs_loc,"LabMeetingJan2021","Fig3","Sel_test_PokingTravel.pdf"))

df1 = combine(groupby(s,:Phase)) do dd
    subdf = unstack(dd,:Treatment,:Trial_Travel_to)
    current_drug = Symbol(subdf[1,:Phase])
    rename!(subdf, current_drug => :Drug)
end
df2 = combine(groupby(df1,[:Phase])) do dd
    wilcoxon(dd,:Control, :Drug; f = x -> mean(skipmissing(x)))
end
Drug_colors!(df2)
plot_wilcoxon(df2; sorting = Plotting_position)
savefig(joinpath(figs_loc,"LabMeetingJan2021","Fig3","Sel_test_ROITravel.pdf"))

################################ Fig4 test Global ##################################
s = filter(r -> r.Phase in ["Optogenetic","Citalopram"], streaks)
df1 = combine(groupby(s,:Phase)) do dd
    subdf = unstack(dd,:Treatment,:Num_pokes)
    current_drug = Symbol(subdf[1,:Phase])
    rename!(subdf, current_drug => :Drug)
end
df2 = combine(groupby(df1,[:Phase])) do dd
    wilcoxon(dd,:Control, :Drug; f = x -> mean(skipmissing(x)))
end
Drug_colors!(df2)
plot_wilcoxon(df2; sorting = Plotting_position)
savefig(joinpath(figs_loc,"LabMeetingJan2021","Fig4","Glob_Test_Numpokes.pdf"))

df1 = combine(groupby(s,:Phase)) do dd
    subdf = unstack(dd,:Treatment,:AfterLast)
    current_drug = Symbol(subdf[1,:Phase])
    rename!(subdf, current_drug => :Drug)
end
df2 = combine(groupby(df1,[:Phase])) do dd
    wilcoxon(dd,:Control, :Drug; f = x -> mean(skipmissing(x)))
end
Drug_colors!(df2)
plot_wilcoxon(df2; sorting = Plotting_position)
savefig(joinpath(figs_loc,"LabMeetingJan2021","Fig4","Glob_Test_AfterLast.pdf"))

df1 = combine(groupby(s,:Phase)) do dd
    subdf = unstack(dd,:Treatment,:Poking_Travel_to)
    current_drug = Symbol(subdf[1,:Phase])
    rename!(subdf, current_drug => :Drug)
end
df2 = combine(groupby(df1,[:Phase])) do dd
    wilcoxon(dd,:Control, :Drug; f = x -> mean(skipmissing(x)))
end
Drug_colors!(df2)
plot_wilcoxon(df2; sorting = Plotting_position)
savefig(joinpath(figs_loc,"LabMeetingJan2021","Fig4","Glob_Test_PokingTravel.pdf"))

df1 = combine(groupby(s,:Phase)) do dd
    subdf = unstack(dd,:Treatment,:Trial_Travel_to)
    current_drug = Symbol(subdf[1,:Phase])
    rename!(subdf, current_drug => :Drug)
end
df2 = combine(groupby(df1,[:Phase])) do dd
    wilcoxon(dd,:Control, :Drug; f = x -> mean(skipmissing(x)))
end
Drug_colors!(df2)
plot_wilcoxon(df2; sorting = Plotting_position)
savefig(joinpath(figs_loc,"LabMeetingJan2021","Fig4","Glob_Test_ROITravel.pdf"))
