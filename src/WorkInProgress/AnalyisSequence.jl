include.(["filtering.jl","TtestFuns.jl","MixedModelsFuns.jl","PlotsFuns.jl"]);
using Dates
gr(size=(600,600), tick_orientation = :out, grid = false,
    linecolor = :black,
    markerstrokecolor = :black,
    thickness_scaling = 2,
    markersize = 6)
##
union(fullS.Phase)
union(fullS.Treatment)
check = combine(groupby(streaks, :Day), [:Phase, :Treatment] .=> (t -> [union(t)]))
open_html_table(check)
##
## Prew at leaving per protocol
plot_perprotocol(streaks, :Leaving_NextPrew, "Control")
    xlabel!("Trial type")
    yaxis!(yticks = (0:0.1:0.4),  ylabel = "Reward probability", ylims = (0.0,0.4))
    plot!([1,3],[0.33,0.33])
    annotate!(2,0.36,Plots.text("n.s.",16))
savefig(joinpath(figs_loc,"Paper","Fig2","B-Prew_Protocol.pdf"))
test_perprotocol(streaks, :Leaving_NextPrew, "Control")
