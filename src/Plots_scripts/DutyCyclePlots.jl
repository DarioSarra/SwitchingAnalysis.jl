using Dates
include("filtering.jl");
# open_html_table(pokes[1:200,:])
##
odc = ODC(pokes)
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
list = ["PreVehicle",
    "Altanserin",
    "SB242084",
    "Way_100135",
    "Methysergide",
    "Citalopram",
    "SB242084_opt",
    "Saline"]

filter!(r -> r.Treatment in list &&
    !r.Reward &&
    r.PokeDuration < 0.4 &&
    r.Trial < 61 &&
    r.MouseID != "pc7",# ["pc1","pc2","pc3","pc4","pc5","pc6","pc8","pc9","pc10"],
    odc)

odc[odc.Treatment .== "PreVehicle",:Treatment] .= "Control"
odc[odc.Treatment .== "Saline",:Treatment] = [o ? "Optogenetic" : "Control" for o in odc[odc.Treatment .== "Saline",:Stim]]
odc[odc.Treatment .== "SB242084_opt",:Phase] .=  "SB242084_opt"
odc[odc.Treatment .== "SB242084_opt",:Treatment] = [o ? "SB242084_opt" : "Control" for o in odc[odc.Treatment .== "SB242084_opt",:Stim]]
## ODC all
df1 = dropmissing(odc)
df2 = combine(groupby(df1,:Treatment)) do dd
    summarize(dd,:PokeFromLeaving,:ODC)
end
Drug_colors!(df2)

@df df2 scatter(:Xaxis, :Mean,
    yerror = :SEM,
    group = :Treatment,
    color = :color,
    xlims = (-1,5.5),
    xflip = true)

## ODC Release
df3 = filter(r -> r.Treatment in ["Optogenetic", "Citalopram", "Control"],df2)
@df df3 scatter(:Xaxis, :Mean,
    yerror = :SEM,
    group = :Treatment,
    color = :color,
    xlims = (-1,10.5),
    xticks = 10:-1:0,
    xflip = true)

## ODC Selective
df3 = filter(r -> r.Treatment in ["SB242084", "Altanserin", "Control"],df2)
@df df3 scatter(:Xaxis, :Mean,
    yerror = :SEM,
    group = :Treatment,
    color = :color,
    xlims = (-1,10.5),
    xticks = 10:-1:0,
    xflip = true)

## ODC Citalopram
df1 = dropmissing(odc)
filter!(r -> r.Phase =="Citalopram", df1)
df2 = combine(groupby(df1,:Treatment)) do dd
    summarize(dd,:PokeFromLeaving,:ODC)
end
Drug_colors!(df2)
df3 = filter(r -> r.Treatment in ["Citalopram", "Control"],df2)
@df df3 scatter(:Xaxis, :Mean,
    yerror = :SEM,
    group = :Treatment,
    color = :color,
    xlims = (-1,10.5),
    xticks = 10:-1:0,
    xflip = true)
## ODC Optogenetic
df1 = dropmissing(odc)
filter!(r -> r.Phase =="Optogenetic", df1)
df2 = combine(groupby(df1,:Treatment)) do dd
    summarize(dd,:PokeFromLeaving,:ODC)
end
Drug_colors!(df2)
df3 = filter(r -> r.Treatment in ["Optogenetic", "Control"],df2)
@df df3 scatter(:Xaxis, :Mean,
    yerror = :SEM,
    group = :Treatment,
    color = :color,
    xlims = (-1,10.5),
    xticks = 10:-1:0,
    xflip = true)
## ODC SB242084
df1 = dropmissing(odc)
filter!(r -> r.Phase =="SB242084", df1)
df2 = combine(groupby(df1,:Treatment)) do dd
    summarize(dd,:PokeFromLeaving,:ODC)
end
Drug_colors!(df2)
df3 = filter(r -> r.Treatment in ["SB242084", "Control"],df2)
@df df3 scatter(:Xaxis, :Mean,
    yerror = :SEM,
    group = :Treatment,
    color = :color,
    xlims = (-1,10.5),
    xticks = 10:-1:0,
    xflip = true)
## ODC Altanserin
df1 = dropmissing(odc)
filter!(r -> r.Phase =="Altanserin", df1)
df2 = combine(groupby(df1,:Treatment)) do dd
    summarize(dd,:PokeFromLeaving,:ODC)
end
Drug_colors!(df2)
df3 = filter(r -> r.Treatment in ["Altanserin", "Control"],df2)
@df df3 scatter(:Xaxis, :Mean,
    yerror = :SEM,
    group = :Treatment,
    color = :color,
    xlims = (-1,10.5),
    xticks = 10:-1:0,
    xflip = true)
## ODC all hierarchy
df1 = dropmissing(odc)
df2 = combine(groupby(df1,:Treatment)) do dd
    summarize(dd,:Poke_Hierarchy,:ODC)
end
Drug_colors!(df2)

@df df2 scatter(:Xaxis, :Mean,
    yerror = :SEM,
    group = :Treatment,
    color = :color,
    legend = :bottomright,
    xlims = (-10.5,5.5))
## ODC Citalopram hierarchy
df1 = dropmissing(odc)
filter!(r -> r.Phase =="Citalopram", df1)
df2 = combine(groupby(df1,:Treatment)) do dd
    summarize(dd,:Poke_Hierarchy,:ODC)
end
Drug_colors!(df2)
df3 = filter(r -> -5 < r.Xaxis < 5,df2)
@df df3 scatter(:Xaxis, :Mean,
    yerror = :SEM,
    group = :Treatment,
    color = :color,
    legend = :bottomright)
## ODC Optogenetic hierarchy
df1 = dropmissing(odc)
filter!(r -> r.Phase =="Optogenetic", df1)
df2 = combine(groupby(df1,:Treatment)) do dd
    summarize(dd,:Poke_Hierarchy,:ODC)
end
Drug_colors!(df2)
df3 = filter(r -> -5 < r.Xaxis < 5,df2)
@df df3 scatter(:Xaxis, :Mean,
    yerror = :SEM,
    group = :Treatment,
    color = :color,
    legend = :bottomright)
## ODC SB242084 hierarchy
df1 = dropmissing(odc)
filter!(r -> r.Phase =="SB242084", df1)
df2 = combine(groupby(df1,:Treatment)) do dd
    summarize(dd,:Poke_Hierarchy,:ODC)
end
Drug_colors!(df2)
df3 = filter(r -> -5 < r.Xaxis < 5,df2)
@df df3 scatter(:Xaxis, :Mean,
    yerror = :SEM,
    group = :Treatment,
    color = :color,
    legend = :bottomright)
## ODC Altanserin hierarchy
df1 = dropmissing(odc)
filter!(r -> r.Phase =="Altanserin", df1)
df2 = combine(groupby(df1,:Treatment)) do dd
    summarize(dd,:Poke_Hierarchy,:ODC)
end
Drug_colors!(df2)
df3 = filter(r -> -5 < r.Xaxis < 5,df2)
@df df3 scatter(:Xaxis, :Mean,
    yerror = :SEM,
    group = :Treatment,
    color = :color,
    legend = :bottomright)
## ODC with Signed Rank over PokeHierarchy Citalopram
df1 = dropmissing(odc)
TREATMENT = "Citalopram"
filter!(r -> r.Phase == TREATMENT &&
    -4 < r.Poke_Hierarchy < 4, df1)
df2 = combine(groupby(df1,:Poke_Hierarchy)) do dd
    dd1 = select(dd,[:MouseID,:Poke_Hierarchy,:Treatment,:ODC])
    subdf = unstack(dd1,:Treatment,:ODC)
end
df3 = combine(groupby(df2,[:Poke_Hierarchy])) do dd
    wilcoxon(dd,Symbol(TREATMENT), :Control; f = x -> mean(skipmissing(x)))
end
plot_wilcoxon(df3)
## ODC with Signed Rank over PokeHierarchy Optogenetic
df1 = dropmissing(odc)
TREATMENT = "Optogenetic"
filter!(r -> r.Phase == TREATMENT &&
    -4 < r.Poke_Hierarchy < 4, df1)
df2 = combine(groupby(df1,:Poke_Hierarchy)) do dd
    dd1 = select(dd,[:MouseID,:Poke_Hierarchy,:Treatment,:ODC])
    subdf = unstack(dd1,:Treatment,:ODC)
end
df3 = combine(groupby(df2,[:Poke_Hierarchy])) do dd
    wilcoxon(dd,Symbol(TREATMENT), :Control; f = x -> mean(skipmissing(x)))
end
plot_wilcoxon(df3)
## ODC with Signed Rank over PokeHierarchy SB242084
df1 = dropmissing(odc)
TREATMENT = "SB242084"
filter!(r -> r.Phase == TREATMENT &&
    -4 < r.Poke_Hierarchy < 4, df1)
df2 = combine(groupby(df1,:Poke_Hierarchy)) do dd
    dd1 = select(dd,[:MouseID,:Poke_Hierarchy,:Treatment,:ODC])
    subdf = unstack(dd1,:Treatment,:ODC)
end
df3 = combine(groupby(df2,[:Poke_Hierarchy])) do dd
    wilcoxon(dd,Symbol(TREATMENT), :Control; f = x -> mean(skipmissing(x)))
end
plot_wilcoxon(df3)
## ODC with Signed Rank over PokeHierarchy Altanserin
df1 = dropmissing(odc)
TREATMENT = "Altanserin"
filter!(r -> r.Phase == TREATMENT &&
    -4 < r.Poke_Hierarchy < 4, df1)
df2 = combine(groupby(df1,:Poke_Hierarchy)) do dd
    dd1 = select(dd,[:MouseID,:Poke_Hierarchy,:Treatment,:ODC])
    subdf = unstack(dd1,:Treatment,:ODC)
end
df3 = combine(groupby(df2,[:Poke_Hierarchy])) do dd
    wilcoxon(dd,Symbol(TREATMENT), :Control; f = x -> mean(skipmissing(x)))
end
plot_wilcoxon(df3)
## ODC with Signed Rank over PokeFromLeaving Citalopram
df1 = dropmissing(odc)
TREATMENT = "Citalopram"
filter!(r -> r.Phase == TREATMENT &&
    -4 < r.PokeFromLeaving < 4, df1)
df2 = combine(groupby(df1,:PokeFromLeaving)) do dd
    dd1 = select(dd,[:MouseID,:PokeFromLeaving,:Treatment,:ODC])
    subdf = unstack(dd1,:Treatment,:ODC)
end
df3 = combine(groupby(df2,[:PokeFromLeaving])) do dd
    wilcoxon(dd,Symbol(TREATMENT), :Control; f = x -> mean(skipmissing(x)))
end
plot_wilcoxon(df3)
## ODC with Signed Rank over PokeFromLeaving Optogenetic
df1 = dropmissing(odc)
TREATMENT = "Optogenetic"
filter!(r -> r.Phase == TREATMENT &&
    -4 < r.PokeFromLeaving < 4, df1)
df2 = combine(groupby(df1,:PokeFromLeaving)) do dd
    dd1 = select(dd,[:MouseID,:PokeFromLeaving,:Treatment,:ODC])
    subdf = unstack(dd1,:Treatment,:ODC)
end
df3 = combine(groupby(df2,[:PokeFromLeaving])) do dd
    wilcoxon(dd,Symbol(TREATMENT), :Control; f = x -> mean(skipmissing(x)))
end
plot_wilcoxon(df3)
## ODC with Signed Rank over PokeFromLeaving SB242084
df1 = dropmissing(odc)
TREATMENT = "SB242084"
filter!(r -> r.Phase == TREATMENT &&
    -4 < r.PokeFromLeaving < 4, df1)
df2 = combine(groupby(df1,:PokeFromLeaving)) do dd
    dd1 = select(dd,[:MouseID,:PokeFromLeaving,:Treatment,:ODC])
    subdf = unstack(dd1,:Treatment,:ODC)
end
df3 = combine(groupby(df2,[:PokeFromLeaving])) do dd
    wilcoxon(dd,Symbol(TREATMENT), :Control; f = x -> mean(skipmissing(x)))
end
plot_wilcoxon(df3)
## ODC with Signed Rank over PokeFromLeaving Altanserin
df1 = dropmissing(odc)
TREATMENT = "Altanserin"
filter!(r -> r.Phase == TREATMENT &&
    -4 < r.PokeFromLeaving < 4, df1)
df2 = combine(groupby(df1,:PokeFromLeaving)) do dd
    dd1 = select(dd,[:MouseID,:PokeFromLeaving,:Treatment,:ODC])
    subdf = unstack(dd1,:Treatment,:ODC)
end
df3 = combine(groupby(df2,[:PokeFromLeaving])) do dd
    wilcoxon(dd,Symbol(TREATMENT), :Control; f = x -> mean(skipmissing(x)))
end
plot_wilcoxon(df3)
