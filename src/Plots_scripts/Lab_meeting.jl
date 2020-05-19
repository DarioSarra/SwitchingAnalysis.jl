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
    r.MouseID != "pc7",
    streaks)
s[s.Treatment .== "Saline",:Treatment] = [o ? "Optogenetic" : "PreVehicle" for o in s[s.Treatment .== "Saline",:Stim]]
s[s.Treatment .== "SB242084_opt",:Phase] .=  "SB242084_opt"
s[s.Treatment .== "SB242084_opt",:Treatment] = [o ? "SB242084_opt" : "PreVehicle" for o in s[s.Treatment .== "SB242084_opt",:Stim]]
# Df = combine([:Treatment,:Stim_Day] => (t,s) -> (treatment = union(t)), groupby(s,:Phase))
df1 = combine(groupby(s,:Phase)) do dd
    subdf = unstack(dd,:Treatment,:Num_pokes)
    current_drug = Symbol(subdf[1,:Phase])
    rename!(subdf, current_drug => :Drug)
end
df2 = combine(groupby(df1,[:Phase])) do dd
    wilcoxon(dd,:Drug, :PreVehicle; f = x -> mean(skipmissing(x)))
end
Drug_colors!(df2)
plot_wilcoxon(df2)
# savefig(joinpath(figs_loc,"Fig3/WilcoxonNumPokes.pdf"))
##
check = filter(r-> occursin("pc",r.MouseID), s)
c = combine([:Stim_Day,:Stim] => (d,s) -> (stimday = union(d),stim = [length(union(s))]), groupby(check,[:MouseID,:Day]))
open_html_table(c)
##
union(s.Phase)
Df = combine(groupby(s,[:Phase,:Treatment])) do dd
    ecdf(dd,:Num_pokes; mode = :conf)
end
# open_html_table(Df)
Drug_colors!(Df)
gd = groupby(Df,:Phase)
tp = [@df subdf plot(:Xaxis, :Mean,
    xlabel = :Phase[1],
    xticks = 0:10:60,
    xrotation = 30,
    group = :Treatment,
    linecolor = :color,
    legend = false,
    ribbon = :ERR,
    linewidth = 2,
    fillalpha = 0.3) for subdf in gd]
ord = [6,1,2,5,3,4]
pp =  plot(tp[ord]...)
##
plot(tp[6])

## Traveltime analysis
df1 = combine(groupby(s,:Phase)) do dd
    subdf = unstack(dd,:Treatment,:Travel_to)
    current_drug = Symbol(subdf[1,:Phase])
    rename!(subdf, current_drug => :Drug)
end
df2 = combine(groupby(df1,[:Phase])) do dd
    wilcoxon(dd,:Drug, :PreVehicle; f = x -> mean(skipmissing(x)))
end
Drug_colors!(df2)
plot_wilcoxon(df2)
##
check = filter(r-> occursin("pc",r.MouseID), streaks)
println.(union(streaks[:,:MouseID]))
union(check[:,:Stim_Day])
union(check[:,:Stim])

df1 = combine(:Num_pokes => mean,groupby(check,[:Treatment,:Stim,:MouseID]))
open_html_table(df1)

df2 = unstack(df1,:Stim,:Num_pokes_mean)
open_html_table(df2)
