include("filtering.jl");
## filter per treatment
list = ["PreVehicle",
    "Altanserin",
    "SB242084",
    "Way_100135",
    "Methysergide",
    "Citalopram"]
s = filter(r->r.Treatment in list &&
    r.Trial < 31,
    streaks)

## number of pokes before leaving
##
Df = combine(groupby(s,[:Phase,:Treatment])) do dd
    ecdf(dd,:Num_pokes; mode = :conf)
end
Drug_colors!(Df)
gd = groupby(Df,:Phase)
tp = [@df subdf plot(:Xaxis, :Mean,
    xlabel = :Phase[1],
    xticks = 0:5:30,
    group = :Treatment,
    linecolor = :color,
    legend = false,
    ribbon = :ERR,
    linewidth = 2,
    fillalpha = 0.3) for subdf in gd]
ord = [5,3,4,2,1]
pp =  plot(tp[ord]...)
note = plot(xlims = (0,0.5), ylims = (0,0.5), annotations = (0.25,0.25,
    Plots.text("mean plus 95% C.I.", :center)),
    border = :none)
plot(vcat(tp[ord],note)...)
savefig(joinpath(figs_loc,"Fig3/CumNumPokes.pdf"))

## Signed rank test Num Pokes
df1 = combine(groupby(s,:Phase)) do dd
    subdf = unstack(dd,:Treatment,:Num_pokes)
    current_drug = Symbol(subdf[1,:Phase])
    rename!(subdf, current_drug => :Drug)
end
df2 = combine(groupby(df1,[:Phase,:MouseID])) do dd
    (Drug = mean(skipmissing(dd[:,:Drug])), PreVehicle = mean(skipmissing(dd[:,:PreVehicle])))
    # wilcoxon(dd,:Drug, :PreVehicle,:MouseID; f = x -> mean(skipmissing(x)))
end
df3 = dropnan(df2)
df4 = combine(groupby(df3,:Phase)) do dd
    wilcoxon(dd,:Drug,:PreVehicle)
end
altern = combine(groupby(df1,[:Phase])) do dd
    wilcoxon(dd,:Drug, :PreVehicle; f = x -> mean(skipmissing(x)))
end
test = DataFrame(a = [NaN,0.4,3.2], b = [1,2,4], c = ["a", "b", "c"])
any(isnan(test[:,:c]))
check = SwitchingAnalysis.complete_vals(test)
any(x -> !x, check)
open_html_table(df4)
Drug_colors!(df4)
plot_wilcoxon(df4)
savefig(joinpath(figs_loc,"Fig3/WilcoxonNumPokes.pdf"))
## Traveltime analysis
df1 = combine(groupby(s,:Phase)) do dd
    subdf = unstack(dd,:Treatment,:Travel_to)
    current_drug = Symbol(subdf[1,:Phase])
    rename!(subdf, current_drug => :Drug)
end
df2 = combine(groupby(df1,[:Phase,:MouseID])) do dd
    (Drug = mean(skipmissing(dd[:,:Drug])), PreVehicle = mean(skipmissing(dd[:,:PreVehicle])))
    # wilcoxon(dd,:Drug, :PreVehicle,:MouseID; f = x -> mean(skipmissing(x)))
end
df3 = dropnan(df2)
df4 = combine(groupby(df3,:Phase)) do dd
    wilcoxon(dd,:Drug,:PreVehicle)
end
open_html_table(df4)
Drug_colors!(df4)
plot_wilcoxon(df4)
savefig(joinpath(figs_loc,"Fig3/WilcoxonTravel.pdf"))
