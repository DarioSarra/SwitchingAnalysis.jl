include.(["filtering.jl","TtestFuns.jl","MixedModelsFuns.jl","PlotsFuns.jl"]);
using Dates, Revise
gr(size=(600,600), tick_orientation = :out, grid = false,
    linecolor = :black,
    markerstrokecolor = :black,
    thickness_scaling = 2,
    markersize = 6)
#=
In setting the constrast matrix we can use:
    - dummy coding to test if a level differs from the reference level
    - effects coding to test if it differs from the mean across levels
=#
contrasts = Dict(
    :Protocol => Center(0.75),
    :Treatment => DummyCoding(; base="Control"), #this tests whether a level differs from the reference level
    :MouseID => Grouping())
transform!(groupby(streaks,[:MouseID,:Day]),
    :Start_trial => (x-> round.((x .- x[1])./60,digits = 0) ) => :Trial_Begin)
##summarize_xy(Alt,:Trial_Begin,:Trial_Travel_to; group = :Treatment,
summarize_xy(Alt,:Trial_Begin,:Trial_Travel_to; group = :Treatment,
    xlabel = "Time (min)", ylabel = "Travel duration(s)", ylims = (0,80),
    left_margin = -40px, bottom_margin = -40px, legend = false)
savefig(joinpath(figs_loc,"Ongoing2022","AltTravelPerformance.pdf"))
summarize_xy(SB,:Trial_Begin,:Trial_Travel_to; group = :Treatment,
    xlabel = "Time (min)", ylabel = "Travel duration(s)", ylims = (0,80),
    left_margin = -40px, bottom_margin = -40px, legend = false)
savefig(joinpath(figs_loc,"Ongoing2022","SBTravelPerformance.pdf"))
summarize_xy(Way,:Trial_Begin,:Trial_Travel_to; group = :Treatment,
    xlabel = "Time (min)", ylabel = "Travel duration(s)", ylims = (0,80),
    left_margin = -40px, bottom_margin = -40px, legend = false)
savefig(joinpath(figs_loc,"Ongoing2022","WayTravelPerformance.pdf"))
summarize_xy(Opto,:Trial_Begin,:Trial_Travel_to; group = :Treatment,
    xlabel = "Time (min)", ylabel = "Travel duration(s)", ylims = (0,80),
    left_margin = -40px, bottom_margin = -40px, legend = false)
savefig(joinpath(figs_loc,"Ongoing2022","OptoTravelPerformance.pdf"))
summarize_xy(Cit,:Trial_Begin,:Trial_Travel_to; group = :Treatment,
    xlabel = "Time (min)", ylabel = "Travel duration(s)", ylims = (0,80),
    left_margin = -40px, bottom_margin = -40px, legend = false)
savefig(joinpath(figs_loc,"Ongoing2022","CitTravelPerformance.pdf"))
summarize_xy(Met,:Trial_Begin,:Trial_Travel_to; group = :Treatment,
    xlabel = "Time (min)", ylabel = "Travel duration(s)", ylims = (0,80),
    left_margin = -40px, bottom_margin = -40px, legend = false)
savefig(joinpath(figs_loc,"Ongoing2022","MetTravelPerformance.pdf"))
summarize_xy(SBOpt,:Trial_Begin,:Trial_Travel_to; group = :Treatment,
    xlabel = "Time (min)", ylabel = "Travel duration(s)", ylims = (0,80),
    left_margin = -40px, bottom_margin = -40px, legend = false)
savefig(joinpath(figs_loc,"Ongoing2022","SBOptTravelPerformance.pdf"))
##
