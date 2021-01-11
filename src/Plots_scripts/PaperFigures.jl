include("filtering.jl");
gr(size=(600,600), tick_orientation = :out, grid = false,
    linecolor = :black,
    markerstrokecolor = :black,
    thickness_scaling = 2,
    markersize = 6)
################################ Poke and Travel analysis ##################################
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
################################ Fig2 scatter  controls ##################################

gd1 = groupby(streaks,[:Protocol,:MouseID,:Phase,:Treatment])
df1 = combine(gd1, :Num_Rewards => mean => :Num_Rewards,:Num_pokes => mean => :Num_pokes, :AfterLast => mean => :AfterLast,:Leaving_NextPrew => mean => :Leaving_NextPrew)

gd2 = groupby(df1,[:Protocol,:Treatment])
df2 = combine(gd2, :Num_Rewards => mean, :Num_Rewards => sem,
    :Num_pokes => mean, :Num_pokes => sem,
    :AfterLast => mean, :AfterLast => sem,
    :Leaving_NextPrew => mean, :Leaving_NextPrew => sem)
filt_2 = filter(r->r.Treatment == "Control",df2)
sort!(filt_2, :Protocol)
@df filt_2 scatter(:Protocol, :Num_Rewards_mean, yerror = :Num_Rewards_sem, label = false, xlims = (0.25,2.75), ylims = (0,6))
savefig(joinpath(figs_loc,"LabMeetingJan2021","Fig2","NumRewards.pdf"))
@df filt_2 scatter(:Protocol, :Num_pokes_mean, yerror = :Num_pokes_sem, label = false, xlims = (0.25,2.75), ylims = (11,15))
savefig(joinpath(figs_loc,"LabMeetingJan2021","Fig2","NumPokes.pdf"))
@df filt_2 scatter(:Protocol, :AfterLast_mean, yerror = :AfterLast_sem, label = false, xlims = (0.25,2.75), ylims = (5,7))
savefig(joinpath(figs_loc,"LabMeetingJan2021","Fig2","AfterLast.pdf"))
@df filt_2 scatter(:Protocol, :Leaving_NextPrew_mean, yerror = :Leaving_NextPrew_sem,label = false, xlims = (0.25,2.75), ylims = (0.2,0.25))
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


fm4 = fit(MixedModel,@formula(AfterLast ~ 1 + (1|MouseID)),age_df,Poisson())
################################ Fig3 scatter  selective ##################################
gd1 = groupby(streaks,[:Protocol,:MouseID,:Phase,:Treatment])
df1 = combine(gd1, :Num_Rewards => mean => :Num_Rewards,:Num_pokes => mean => :Num_pokes, :AfterLast => mean => :AfterLast,:Actual_Leaving_Prew => mean => :Leaving_Prew)

gd2 = groupby(df1,[:Protocol,:Treatment])
df2 = combine(gd2, :Num_Rewards => mean, :Num_Rewards => sem,
    :Num_pokes => mean, :Num_pokes => sem,
    :AfterLast => mean, :AfterLast => sem,
    :Leaving_Prew => mean, :Leaving_Prew => sem)
filt_2 = filter(r->r.Treatment == "SB242084",df2)
sort!(filt_2, :Protocol)
@df filt_2 scatter(:Protocol, :Num_Rewards_mean, yerror = :Num_Rewards_sem, label = false, xlims = (0.25,2.75), ylims = (0,6))
savefig(joinpath(figs_loc,"LabMeetingJan2021","Fig3","SB_NumRewards.pdf"))
@df filt_2 scatter(:Protocol, :Num_pokes_mean, yerror = :Num_pokes_sem, label = false, xlims = (0.25,2.75))
savefig(joinpath(figs_loc,"LabMeetingJan2021","Fig3","SB_NumPokes.pdf"))
@df filt_2 scatter(:Protocol, :AfterLast_mean, yerror = :AfterLast_sem, label = false, xlims = (0.25,2.75))
savefig(joinpath(figs_loc,"LabMeetingJan2021","Fig3","SB_AfterLast.pdf"))
@df filt_2 scatter(:Protocol, :Leaving_Prew_mean, yerror = :Leaving_Prew_sem,label = false, xlims = (0.25,2.75), ylims =(0,1))
savefig(joinpath(figs_loc,"LabMeetingJan2021","Fig3","SB_Prew.pdf"))

filt_2 = filter(r->r.Treatment == "Altanserin",df2)
sort!(filt_2, :Protocol)
@df filt_2 scatter(:Protocol, :Num_Rewards_mean, yerror = :Num_Rewards_sem, label = false, xlims = (0.25,2.75), ylims = (0,6))
savefig(joinpath(figs_loc,"LabMeetingJan2021","Fig3","Alt_NumRewards.pdf"))
@df filt_2 scatter(:Protocol, :Num_pokes_mean, yerror = :Num_pokes_sem, label = false, xlims = (0.25,2.75))
savefig(joinpath(figs_loc,"LabMeetingJan2021","Fig3","Alt_NumPokes.pdf"))
@df filt_2 scatter(:Protocol, :AfterLast_mean, yerror = :AfterLast_sem, label = false, xlims = (0.25,2.75))
savefig(joinpath(figs_loc,"LabMeetingJan2021","Fig3","Alt_AfterLast.pdf"))
@df filt_2 scatter(:Protocol, :Leaving_Prew_mean, yerror = :Leaving_Prew_sem,label = false, xlims = (0.25,2.75), ylims =(0,1))
savefig(joinpath(figs_loc,"LabMeetingJan2021","Fig3","Alt_Prew.pdf"))

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
