include("filtering.jl");
## Number of pokes during the session

Df = combine(groupby(streaks,:Phase)) do dd
    summarize(dd,:Trial,:Num_pokes)
end
Drug_colors!(Df)
@df Df plot(:Xaxis,:Mean,
    group = :Phase,
    color = :color,
    ribbon = :SEM,
    linewidth = 2,
    fillalpha = 0.1,
    xticks = 0:10:100)
savefig(joinpath(figs_loc,"Fig1/trials_selected.pdf"))
