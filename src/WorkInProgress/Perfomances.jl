include.(["filtering.jl","TtestFuns.jl","MixedModelsFuns.jl","PlotsFuns.jl"]);
using Dates
gr(size=(600,600), tick_orientation = :out, grid = false,
    linecolor = :black,
    markerstrokecolor = :black,
    thickness_scaling = 2,
    markersize = 6)
transform!(groupby(streaks,[:MouseID,:Day]),
    :Start_trial => (x-> round.((x .- x[1])./60,digits = 0) ) => :Trial_Begin)
## Number of pokes
Alt = filter(r -> r.Phase == "Altanserin", streaks)
summarize_xy(Alt,:Trial,:Num_pokes; group = :Treatment,
    xlabel = "Trial", ylabel = "# Pokes", ylims = (0,25),
    left_margin = -40px, bottom_margin = -40px)
savefig(joinpath(figs_loc,"Ongoing2022","AltNumPokes.pdf"))
##
SB = filter(r -> r.Phase == "SB242084", streaks)
summarize_xy(SB,:Trial,:Num_pokes; group = :Treatment,
    xlabel = "Trial", ylabel = "# Pokes", ylims = (0,25),
    left_margin = -40px, bottom_margin = -40px)
savefig(joinpath(figs_loc,"Ongoing2022","SBNumPokes.pdf"))
##
Way = filter(r -> r.Phase == "Way_100135", streaks)
summarize_xy(Way,:Trial,:Num_pokes; group = :Treatment,
    xlabel = "Trial", ylabel = "# Pokes", ylims = (0,25),
    left_margin = -40px, bottom_margin = -40px)
savefig(joinpath(figs_loc,"Ongoing2022","WayNumPokes.pdf"))
##
Cit = filter(r -> r.Phase == "Citalopram", streaks)
summarize_xy(Cit,:Trial,:Num_pokes; group = :Treatment,
    xlabel = "Trial", ylabel = "# Pokes", ylims = (0,25),
    left_margin = -40px, bottom_margin = -40px)
savefig(joinpath(figs_loc,"Ongoing2022","CitNumPokes.pdf"))
##
Opto = filter(r -> r.Phase == "Optogenetic", streaks)
summarize_xy(Opto,:Trial,:Num_pokes; group = :Treatment,
    xlabel = "Trial", ylabel = "# Pokes", ylims = (0,25),
    left_margin = -40px, bottom_margin = -40px)
savefig(joinpath(figs_loc,"Ongoing2022","OptoNumPokes.pdf"))
##
Met = filter(r -> r.Phase == "Methysergide", streaks)
summarize_xy(Met,:Trial,:Num_pokes; group = :Treatment,
    xlabel = "Trial", ylabel = "# Pokes", ylims = (0,25),
    left_margin = -40px, bottom_margin = -40px)
savefig(joinpath(figs_loc,"Ongoing2022","MetNumPokes.pdf"))
##
SB_Opt = filter(r -> r.Phase == "SB242084_opt", streaks)
summarize_xy(SB_Opt,:Trial,:Num_pokes; group = :Treatment,
    xlabel = "Trial", ylabel = "# Pokes", ylims = (0,25),
    left_margin = -40px, bottom_margin = -40px)
savefig(joinpath(figs_loc,"Ongoing2022","SB_OptNumPokes.pdf"))
##
summarize_xy(Alt,:Trial_Begin,:Trial; group = :Treatment,
    xlabel = "Time (min)", ylabel = "# Trials", ylims = (0,90),
    left_margin = -40px, bottom_margin = -40px, legend = :topleft)
savefig(joinpath(figs_loc,"Ongoing2022","AltTrials.pdf"))
##
summarize_xy(SB,:Trial_Begin,:Trial; group = :Treatment,
    xlabel = "Time (min)", ylabel = "# Trials", ylims = (0,90),
    left_margin = -40px, bottom_margin = -40px, legend = :topleft)
savefig(joinpath(figs_loc,"Ongoing2022","SBTrials.pdf"))
##
summarize_xy(Way,:Trial_Begin,:Trial; group = :Treatment,
    xlabel = "Time (min)", ylabel = "# Trials", ylims = (0,90),
    left_margin = -40px, bottom_margin = -40px, legend = :topleft)
savefig(joinpath(figs_loc,"Ongoing2022","WayTrials.pdf"))
##
summarize_xy(Opto,:Trial_Begin,:Trial; group = :Treatment,
    xlabel = "Time (min)", ylabel = "# Trials", ylims = (0,90),
    left_margin = -40px, bottom_margin = -40px, legend = :topleft)
savefig(joinpath(figs_loc,"Ongoing2022","OptoTrials.pdf"))
##
summarize_xy(Cit,:Trial_Begin,:Trial; group = :Treatment,
    xlabel = "Time (min)", ylabel = "# Trials", ylims = (0,90),
    left_margin = -40px, bottom_margin = -40px, legend = :topleft)
savefig(joinpath(figs_loc,"Ongoing2022","CitTrials.pdf"))
##
summarize_xy(Met,:Trial_Begin,:Trial; group = :Treatment,
    xlabel = "Time (min)", ylabel = "# Trials", ylims = (0,90),
    left_margin = -40px, bottom_margin = -40px, legend = :topleft)
savefig(joinpath(figs_loc,"Ongoing2022","MetTrials.pdf"))
##
summarize_xy(SB_Opt,:Trial_Begin,:Trial; group = :Treatment,
    xlabel = "Time (min)", ylabel = "# Trials", ylims = (0,90),
    left_margin = -40px, bottom_margin = -40px, legend = :topleft)
savefig(joinpath(figs_loc,"Ongoing2022","SB_OptTrials.pdf"))
