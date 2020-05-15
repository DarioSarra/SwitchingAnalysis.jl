include("filtering.jl");
## filter per treatment
list = ["PreVehicle",
    "Altanserin",
    "SB242084",
    "Way_100135",
    "Methysergide",
    "Citalopram"]
s = filter(r->r.Treatment in list &&
    r.Trial < 61,
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

## Delta pokes per trial

gd = groupby(s,:Phase)
df1 = combine(gd) do dd
    effect_size(dd,:Treatment,:Num_pokes; baseline = "PreVehicle")
end
df1[:,:Position] = [get(Treatment_dict, x, "unknown") for x in df1[:,:Phase]]
sort!(df1,[:Position,:MouseID])
@df df1 scatter(:Phase, :Effect,
    color = :grey,
    markeralpha = 0.5)
gd1 = groupby(df1,:Phase)
df2 = combine(gd1) do dd
        ci = confint(OneSampleTTest(jump_missing(dd[:,:Effect])))
        m = mean(jump_missing(dd[:,:Effect]))
        (Mean = m,
        ErrLow = m - ci[1],
        ErrUp = ci[2] -m)
    end
df2.Err = [(low,up) for (low,up) in zip(df2.ErrLow, df2.ErrUp)]
df2[:,:Position] = [get(Treatment_dict, x, "unknown") for x in df2[:,:Phase]]
sort!(df2,[:Position])
Drug_colors!(df2)
@df df2 scatter!(:Phase,:Mean,
    yerr = :Err,
    color = :color,
    linecolor = :black,
    markersize = 10,
    label  = false)
Plots.abline!(0,0,color = :black)
savefig(joinpath(figs_loc,"Fig3/DeltaNumPokes.pdf"))
##
