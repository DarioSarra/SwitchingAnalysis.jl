include("filtering.jl");
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
