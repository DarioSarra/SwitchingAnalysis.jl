using Dates
include("filtering.jl");
# open_html_table(pokes[1:200,:])
odc = ODC(pokes)
##
open_html_table(odc[1:200,:])
@df odc density(:PokeDuration,group = :Reward,
    linecolor = :auto,  color_palette = [:black,:blue],
    xticks = 0:0.25:4)
xpos1 = 0.4
xpos2 = 0.7
ypos1 = 0.0
ypos2 = 7.5
plot!(Shape([(0,ypos1), (xpos1,ypos1),(xpos1,ypos2),(0,ypos2)]),
    fillalpha = 0.1,linewidth = 0, fillcolor = :black)
plot!(Shape([(xpos2,ypos1), (3.5,ypos1),(3.5,ypos2),(xpos2,ypos2)]),
    fillalpha = 0.1,linewidth = 0, fillcolor = :blue)
##
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
    r.Trial < 31 &&
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
allignment = :PokeFromLeaving
phases = ["Citalopram","Optogenetic","Methysergide","SB242084","Altanserin","Way_100135"]
ps = plot_odc(odc, phases,allignment; limit = 5)
##  ODC Poke Hierarchy
allignment = :Poke_Hierarchy
phases = ["Citalopram","Optogenetic","Methysergide","SB242084","Altanserin","Way_100135"]
ps = plot_odc(odc, phases,allignment; limit = 5)
plot(ps...)
##  ODC Poke From Last Reward
allignment = :PokeFromLastRew
phases = ["Citalopram","Optogenetic","Methysergide","SB242084","Altanserin","Way_100135"]
ps = plot_odc(odc, phases,allignment; limit = 5)
plot(ps...)
