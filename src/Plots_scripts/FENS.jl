include("filtering.jl");
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
##
s = filter(r -> r.Phase in ["Optogenetic", "Citalopram"], streaks)
##
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
##
savefig(joinpath(figs_loc,"FENS/Plot5_NumPokes_50trials.pdf"))
##
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
##
savefig(joinpath(figs_loc,"FENS/Plot9_Afterlast_50trials.pdf"))
##
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
##
savefig(joinpath(figs_loc,"FENS/Plot7_PokingTravel_50trials.pdf"))
##
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
##
savefig(joinpath(figs_loc,"FENS/Plot8_ROITravel_50trials.pdf"))
##
df1 = combine(groupby(s,:Phase)) do dd
    subdf = unstack(dd,:Treatment,:ROILeavingTime)
    current_drug = Symbol(subdf[1,:Phase])
    rename!(subdf, current_drug => :Drug)
end
df2 = combine(groupby(df1,[:Phase])) do dd
    wilcoxon(dd,:Control, :Drug; f = x -> mean(skipmissing(x)))
end
Drug_colors!(df2)
plot_wilcoxon(df2; sorting = Plotting_position)
##
savefig(joinpath(figs_loc,"FENS/Plot14_ROILeaving_50trials.pdf"))
################################ Leaving analysis ##################################
odc = ODC(pokes)
@df filter(r -> r.PokeDuration < 4,odc) density(:PokeDuration,group = :Reward)
plot!(repeat([0.43],2), [0,8])
plot!(repeat([0.7],2), [0,8])
odc[!,:ClearDuration] = [r.Reward ? r.PokeDuration > 0.7 : r.PokeDuration < 0.4 for r in eachrow(odc)]
list = ["PreVehicle",
    "Altanserin",
    "SB242084",
    "Way_100135",
    "Methysergide",
    "Citalopram",
    "SB242084_opt",
    "Saline"]

filter!(r -> r.Treatment in list &&
    !ismissing(r.Pre_Interpoke) &&
    r.Pre_Interpoke < 0.5 &&
    r.ClearDuration &&
    r.Trial < 51 &&
    r.MouseID != "d5" &&
    r.MouseID != "pc7",# ["pc1","pc2","pc3","pc4","pc5","pc6","pc8","pc9","pc10"],
    odc)

odc[odc.Treatment .== "PreVehicle",:Treatment] .= "Control"
odc[odc.Treatment .== "Saline",:Treatment] = [o ? "Optogenetic" : "Control" for o in odc[odc.Treatment .== "Saline",:Stim]]
odc[odc.Treatment .== "SB242084_opt",:Phase] .=  "SB242084_opt"
odc[odc.Treatment .== "SB242084_opt",:Treatment] = [o ? "SB242084_opt" : "Control" for o in odc[odc.Treatment .== "SB242084_opt",:Stim]]


df1 = filter(r -> !r.Reward &&
    r.ExpDay > 3 &&
    !ismissing(r.PokeFromLastRew) &&
    0 < r.PokeFromLastRew &&
    !ismissing(r.ODC) &&
    r.Treatment in ["Control","Citalopram", "Optogenetic", "Altanserin","SB242084"] &&
    !in(r.Phase,["Methysergide", "Way_100135","SB242084_opt"]) ,odc)

categorical!(df1,[:MouseID,:Treatment,:Phase])

levels!(df1.Treatment, ["Control",
    "Citalopram",
    "Optogenetic",
    "Altanserin",
    "SB242084"])

transform!(groupby(df1,[:MouseID,:Phase,:Treatment]), :ODC => mean => :ODC_mean)
df1[!,:NODC] = df1.ODC ./ df1.ODC_mean
transform!(groupby(df1,[:MouseID,:Phase,:Treatment]), :NODC => binquantile => :QODC)
df1[!,:Leave] = [r == 0 for r in df1.PokeFromLeaving]
##
filtered = filter(r -> r.PokeFromLeaving < 6 && r.Phase in ["Citalopram"], df1)
ps = plot_QODC(filtered,:PokeFromLeaving; xflip = true, ylims = :auto)
##
savefig(joinpath(figs_loc,"FENS/Plot11_QODCfromLeaving_50trials.pdf"))
##
filtered = filter(r -> r.PokeFromLeaving == 0 &&
    r.Phase in ["Optogenetic","Citalopram","SB242084","Altanserin"], df1)
gd2 = groupby(filtered,[:MouseID,:Phase,:Treatment])
df2 = combine(gd2, :QODC => mean => :QODC)
gd3 = groupby(df2,[:Phase])
df3 = combine(gd3) do dd
    dd[:,:Treatment] = [t == "Control" ? t : "Manipulation" for t in dd.Treatment]
    unstack(dd,:Treatment, :QODC)
end
dropmissing!(df3)
gd4 = groupby(df3,:Phase)
df4 = combine(gd4) do dd
    wilcoxon(dd,:Control,:Manipulation)
end
df4[!,:Phase] = String.(df4.Phase)
Drug_colors!(df4)
plot_wilcoxon(df4; sorting = Plotting_position)
##
savefig(joinpath(figs_loc,"FENS/Plot13_QODCatLeaving_50trials.pdf"))
