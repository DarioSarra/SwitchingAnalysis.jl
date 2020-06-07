using Dates
include("filtering.jl");
##
odc = ODC(pokes)
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
    r.ClearDuration &&
    r.Trial < 61 &&
    r.MouseID != "pc7",# ["pc1","pc2","pc3","pc4","pc5","pc6","pc8","pc9","pc10"],
    odc)

@df odc density(:PokeDuration,group = :Reward,
    linecolor = :auto,  color_palette = [:black,:blue],
    xticks = 0:0.25:4)

odc[odc.Treatment .== "PreVehicle",:Treatment] .= "Control"
odc[odc.Treatment .== "Saline",:Treatment] = [o ? "Optogenetic" : "Control" for o in odc[odc.Treatment .== "Saline",:Stim]]
odc[odc.Treatment .== "SB242084_opt",:Phase] .=  "SB242084_opt"
odc[odc.Treatment .== "SB242084_opt",:Treatment] = [o ? "SB242084_opt" : "Control" for o in odc[odc.Treatment .== "SB242084_opt",:Stim]]
## ODC from last reward
df1 =  filter(r -> !ismissing(r.ODC) &&
    !r.Reward &&
    !ismissing(r.PokeFromLastRew) &&
    -5 < r.PokeFromLastRew < 5 &&
    r.Treatment in ["Control"],
    odc)
# open_html_table(df1[1:200,[:Trial,:PokeFromTrial,:PokeFromLastRew]])
df2 = combine(groupby(df1,:Treatment)) do dd
    summarize(dd,:Poke_Hierarchy,:ODC)
end
Drug_colors!(df2)
@df df2 scatter(:Xaxis, :Mean,
    yerror = :SEM,
    group = :Treatment,
    color = :color)
## ODC Poke From Leaving
phases = ["Citalopram","Optogenetic","SB242084","Altanserin"]
allignment = :PokeFromLeaving
ps1 = plot_odc(odc, phases,allignment; limit = 5)
filename1 = string(allignment) * ".pdf"
savefig(joinpath(figs_loc,"ODC",filename1))
ps2 = plot_wilcoxon_odc(odc, phases,allignment; limit = 5)
filename2 = string(allignment) * "Test.pdf"
savefig(joinpath(figs_loc,"ODC",filename2))
##  ODC Poke Hierarchy
allignment = :Poke_Hierarchy
ps1 = plot_odc(odc, phases,allignment; limit = 5)
filename1 = string(allignment) * ".pdf"
savefig(joinpath(figs_loc,"ODC",filename1))
ps2 = plot_wilcoxon_odc(odc, phases,allignment; limit = 5)
filename2 = string(allignment) * "Test.pdf"
savefig(joinpath(figs_loc,"ODC",filename2))
##  ODC Poke From Last Reward
allignment = :PokeFromLastRew
ps1 = plot_odc(odc, phases,allignment; limit = 5)
filename1 = string(allignment) * ".pdf"
savefig(joinpath(figs_loc,"ODC",filename1))
ps2 = plot_wilcoxon_odc(odc, phases,allignment; limit = 5)
filename2 = string(allignment) * "Test.pdf"
savefig(joinpath(figs_loc,"ODC",filename2))
## Delta before-after last reward ODC in control data
df1 = filter(r -> r.Treatment == "Control" &&
    !r.Reward &&
    !ismissing(r.PokeFromLastRew) &&
    r.PokeFromLastRew in [-1,1] &&
    !ismissing(r.ODC), odc)
df2 = combine(:ODC => mean => :ODC, groupby(df1,[:Phase,:MouseID, :PokeFromLastRew]))
df3 = unstack(df2,:PokeFromLastRew,:ODC)
df3[!,:Delta_odc] = df3[:,3] .- df3[:,4]
df4 = dropmissing(df3)
df5 = wilcoxon(df4, Symbol(-1), Symbol(1))
plot_wilcoxon(df5)
filename1 = "DeltaODC_allcontrol.pdf"
savefig(joinpath(figs_loc,"ODC",filename1))
gd = groupby(df4,:Phase)
df6 = combine(gd) do dd
    wilcoxon(dd, Symbol(-1), Symbol(1))
end
plot_wilcoxon(df6)
filename2 = "DeltaODC_separatecontrol.pdf"
savefig(joinpath(figs_loc,"ODC",filename2))
## lm of manipulation after last reward
using GLM, MixedModels
odc = ODC(pokes)
odc[!,:ClearDuration] = [r.Reward ? r.PokeDuration > 0.7 : r.PokeDuration < 0.4 for r in eachrow(odc)]
list = ["None",
    "PreVehicle",
    "Altanserin",
    "SB242084",
    "Way_100135",
    "Methysergide",
    "Citalopram",
    "SB242084_opt",
    "Saline"]
filter!(r -> r.Treatment in list &&
    r.ClearDuration &&
    r.Trial < 61 &&
    r.MouseID != "pc7",# ["pc1","pc2","pc3","pc4","pc5","pc6","pc8","pc9","pc10"],
    odc)

union(odc.Treatment)
odc[odc.Treatment .== "PreVehicle",:Treatment] .= "Control"
odc[odc.Treatment .== "None",:Treatment] .= "Control"
odc[odc.Treatment .== "Saline",:Treatment] = [o ? "Optogenetic" : "Control" for o in odc[odc.Treatment .== "Saline",:Stim]]
odc[odc.Treatment .== "SB242084_opt",:Phase] .=  "SB242084_opt"
odc[odc.Treatment .== "SB242084_opt",:Treatment] = [o ? "SB242084_opt" : "Control" for o in odc[odc.Treatment .== "SB242084_opt",:Stim]]

df1 = filter(r -> !r.Reward &&
    r.ExpDay > 3 &&
    !ismissing(r.PokeFromLastRew) &&
    r.PokeFromLastRew > 0 &&
    !ismissing(r.ODC), odc)
df1[!,:Treatment] = [ t == "Control" ? "Control" : "Manipulation"  for t in df1.Treatment]
println.(union(df1.Phase))
categorical!(df1,[:MouseID,:Treatment,:Phase])
levels!(df1.Treatment, ["Control", "Manipulation"])
levels!(df1.Phase, ["training",
    "Citalopram",
    "Methysergide",
    "Altanserin",
    "Way_100135",
    "SB242084",
    "Optogenetic",
    "SB242084_opt"])
##
mdl1 = @formula(ODC ~ 1 + PokeFromLastRew + (1|MouseID))
mdl2 = @formula(ODC ~ 1 + PokeFromLastRew + Treatment*Phase + (1|MouseID))
fm1 = fit!(LinearMixedModel(mdl1,df1))
fm2 = fit!(LinearMixedModel(mdl2,df1))
aic(fm1) > aic(fm2)

control_data = filter(r -> r.Phase == "training", df1)
@df control_data scatter(:PokeFromLastRew,:ODC)
