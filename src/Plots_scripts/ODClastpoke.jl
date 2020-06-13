include("filtering.jl");
##
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
    in(r.Phase,["Control","Citalopram", "Optogenetic", "Altanserin","SB242084","Methysergide", "Way_100135","SB242084_opt"]) ,odc)
    # &&
    # r.Treatment in ["Control","Citalopram", "Optogenetic", "Altanserin","SB242084"] &&

categorical!(df1,[:MouseID,:Treatment,:Phase])

levels!(df1.Treatment, ["Control",
    "Citalopram",
    "Optogenetic",
    "Altanserin",
    "SB242084",
    "Methysergide",
    "Way_100135",
    "SB242084_opt"])

transform!(groupby(df1,[:MouseID,:Phase,:Treatment]), :ODC => mean => :ODC_mean)
df1[!,:NODC] = df1.ODC ./ df1.ODC_mean
transform!(groupby(df1,[:MouseID,:Phase,:Treatment]), :NODC => binquantile => :QODC)
df1[!,:Leave] = [r == 0 for r in df1.PokeFromLeaving]
##
filtered = filter(r -> r.PokeFromLeaving == 0, df1)
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

savefig(joinpath(figs_loc,"ODC","ODC_from_leaving","ALLWilcoxonQODC_leaving50trials.pdf"))
##
df5 = filter(r -> r.Phase in ["Optogenetic", "Citalopram","Altanserin", "SB242084"],df4)
plot_wilcoxon(df5)
df5[!,:x] = [2,1]
open_html_table(df5)
select!(df5,[:x,:Phase,:Median,:CI,:Vals,:color])
sorting = Dict()
for (v,k) in enumerate(sort(df5[:,2]))
    sorting[k] = v
end
sorting
xticks!([1,2],["Optogenetic", "Citalopram"])
xlims!(0.5,2.5)
df6 = flatten(df5,:Vals)
@df df6 scatter(:x, :Vals, markercolor = :grey, xlims = (0.5,2.5), xticks = ([1,2],["Optogenetic","Citalopram"]))
sortig
position = []
original = []
for (k,v) in sorting
 push!(position,v)
 push!(original,k)
end
(position,original)
