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
    color = :color,
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

#savefig(joinpath(figs_loc,"Fig3/DeltaNumPokes.pdf"))
## Signed rank test
df1 = combine(groupby(s,[:Phase, :Treatment, :MouseID])) do dd
    (NumPokes = mean(dd[:,:Num_pokes]),)
end

df2 = combine(groupby(df1,:Phase)) do dd
    subdf = unstack(dd,:Treatment,:NumPokes)
    current_drug = Symbol(subdf[1,:Phase])
    rename!(subdf, current_drug => :Drug)
    dropmissing!(subdf)
end

df3 = combine(groupby(df2,:Phase)) do dd
    (Wilcoxon = SignedRankTest(dd.Drug,dd.PreVehicle),)
end
df3[!,:Median] = [t.median for t in df3[:,:Wilcoxon]]
df3[!,:Values] = [t.vals for t in df3[:,:Wilcoxon]]
df3[!,:CI] = [(t.median - confint(t)[1], confint(t)[2] - t.median) for t in df3[:,:Wilcoxon]]
df3[!,:P] = [pvalue(t) for t in df3[:,:Wilcoxon]]
T = df3[1,:Wilcoxon]
Drug_colors!(df3)
df3[!,:Pos] = [get(Treatment_dict,x,10) for x in df3[:,:Phase]]
sort!(df3,:Pos)
df4 = flatten(df3,:Values)
@df df4 scatter(:Phase, :Values, color = :grey,
    markeralpha = 0.4,
    markercolor = :grey)
Plots.abline!(0,0,color = :black, linestyle = :dash)
@df df3 scatter!(:Phase,:Median,
    yerror = :CI,
    linecolor = :black,
    markerstrokecolor = :black,
    markersize = 10,
    legend = false,
    tickfont = (7, :black),
    color = :color,
    ylabel = "Signed rank test - median and 95% c.i.",
    xlabel = "Treatment")
##
savefig(joinpath(figs_loc,"Fig3/WilcoxonSignedRankTest.pdf"))
