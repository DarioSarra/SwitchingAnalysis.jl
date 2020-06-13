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
    r.Trial < 51 &&
    # r.Trial_Travel_to < 40 &&
    r.MouseID != "pc7",
    streaks)
s[s.Treatment .== "PreVehicle",:Treatment] .= "Control"
s[s.Treatment .== "Saline",:Treatment] = [o ? "Optogenetic" : "Control" for o in s[s.Treatment .== "Saline",:Stim]]
s[s.Treatment .== "SB242084_opt",:Phase] .=  "SB242084_opt"
s[s.Treatment .== "SB242084_opt",:Treatment] = [o ? "SB242084_opt" : "Control" for o in s[s.Treatment .== "SB242084_opt",:Stim]]
# Df = combine([:Treatment,:Stim_Day] => (t,s) -> (treatment = union(t)), groupby(s,:Phase))
######################## All  Manipulations ###################################
df1 = combine(groupby(s,:Phase)) do dd
    subdf = unstack(dd,:Treatment,:Num_pokes)
    current_drug = Symbol(subdf[1,:Phase])
    rename!(subdf, current_drug => :Drug)
end
df2 = combine(groupby(df1,[:Phase])) do dd
    wilcoxon(dd,:Control, :Drug; f = x -> mean(skipmissing(x)))
end
Drug_colors!(df2)
plot_wilcoxon(df2)
##
savefig(joinpath(figs_loc,"LabMeeting/WilcoxonNumPokes50.pdf"))
##
df1 = combine(groupby(s,:Phase)) do dd
    subdf = unstack(dd,:Treatment,:Trial_Travel_to)
    current_drug = Symbol(subdf[1,:Phase])
    rename!(subdf, current_drug => :Drug)
end
df2 = combine(groupby(df1,[:Phase])) do dd
    wilcoxon(dd,:Drug, :Control; f = x -> mean(skipmissing(x)))
end
Drug_colors!(df2)
plot_wilcoxon(df2)
##
savefig(joinpath(figs_loc,"LabMeeting/WilcoxonTravelROI50.pdf"))
##
df1 = combine(groupby(s,:Phase)) do dd
    subdf = unstack(dd,:Treatment,:Poking_Travel_to)
    current_drug = Symbol(subdf[1,:Phase])
    rename!(subdf, current_drug => :Drug)
end
df2 = combine(groupby(df1,[:Phase])) do dd
    wilcoxon(dd,:Drug, :Control; f = x -> mean(skipmissing(x)))
end
Drug_colors!(df2)
plot_wilcoxon(df2)
##
savefig(joinpath(figs_loc,"LabMeeting/WilcoxonTravelPOKES50.pdf"))
##
df1 = combine(groupby(s,:Phase)) do dd
    subdf = unstack(dd,:Treatment,:AfterLast)
    current_drug = Symbol(subdf[1,:Phase])
    rename!(subdf, current_drug => :Drug)
end
df2 = combine(groupby(df1,[:Phase])) do dd
    wilcoxon(dd,:Drug, :Control; f = x -> mean(skipmissing(x)))
end
Drug_colors!(df2)
plot_wilcoxon(df2)
##
savefig(joinpath(figs_loc,"LabMeeting/WilcoxonAfterLast50.pdf"))
######################## 5HT Release  Manipulations ###################################
release_man =  filter(r -> r.Phase in ["Citalopram", "Optogenetic"], s)
df1 = combine(groupby(release_man,:Phase)) do dd
    subdf = unstack(dd,:Treatment,:Num_pokes)
    current_drug = Symbol(subdf[1,:Phase])
    rename!(subdf, current_drug => :Drug)
end
df2 = combine(groupby(df1,[:Phase])) do dd
    wilcoxon(dd,:Drug, :Control; f = x -> mean(skipmissing(x)))
end
Drug_colors!(df2)
plot_wilcoxon(df2)
##
savefig(joinpath(figs_loc,"LabMeeting/ReleaseNumPokes50.pdf"))
##
df1 = combine(groupby(release_man,:Phase)) do dd
    subdf = unstack(dd,:Treatment,:Trial_Travel_to)
    current_drug = Symbol(subdf[1,:Phase])
    rename!(subdf, current_drug => :Drug)
end
df2 = combine(groupby(df1,[:Phase])) do dd
    wilcoxon(dd,:Drug, :Control; f = x -> mean(skipmissing(x)))
end
Drug_colors!(df2)
plot_wilcoxon(df2)
##
savefig(joinpath(figs_loc,"LabMeeting/ReleaseTravelROI50.pdf"))
##
df1 = combine(groupby(release_man,:Phase)) do dd
    subdf = unstack(dd,:Treatment,:Poking_Travel_to)
    current_drug = Symbol(subdf[1,:Phase])
    rename!(subdf, current_drug => :Drug)
end
df2 = combine(groupby(df1,[:Phase])) do dd
    wilcoxon(dd,:Drug, :Control; f = x -> mean(skipmissing(x)))
end
Drug_colors!(df2)
plot_wilcoxon(df2)
##
savefig(joinpath(figs_loc,"LabMeeting/ReleaseTravelPOKEES50.pdf"))
##
df1 = combine(groupby(release_man,:Phase)) do dd
    subdf = unstack(dd,:Treatment,:AfterLast)
    current_drug = Symbol(subdf[1,:Phase])
    rename!(subdf, current_drug => :Drug)
end
df2 = combine(groupby(df1,[:Phase])) do dd
    wilcoxon(dd,:Drug, :Control; f = x -> mean(skipmissing(x)))
end
Drug_colors!(df2)
plot_wilcoxon(df2)
##
savefig(joinpath(figs_loc,"LabMeeting/ReleaseAfterLast50.pdf"))
######################## Global  Manipulations ###################################
glob_man =  filter(r -> r.Phase in ["Citalopram", "Optogenetic", "Methysergide"], s)
df1 = combine(groupby(glob_man,:Phase)) do dd
    subdf = unstack(dd,:Treatment,:Num_pokes)
    current_drug = Symbol(subdf[1,:Phase])
    rename!(subdf, current_drug => :Drug)
end
df2 = combine(groupby(df1,[:Phase])) do dd
    wilcoxon(dd,:Drug, :Control; f = x -> mean(skipmissing(x)))
end
Drug_colors!(df2)
plot_wilcoxon(df2)
##
savefig(joinpath(figs_loc,"LabMeeting/GlobalNumPokes50.pdf"))
##
df1 = combine(groupby(glob_man,:Phase)) do dd
    subdf = unstack(dd,:Treatment,:Trial_Travel_to)
    current_drug = Symbol(subdf[1,:Phase])
    rename!(subdf, current_drug => :Drug)
end
df2 = combine(groupby(df1,[:Phase])) do dd
    wilcoxon(dd,:Drug, :Control; f = x -> mean(skipmissing(x)))
end
Drug_colors!(df2)
plot_wilcoxon(df2)
##
savefig(joinpath(figs_loc,"LabMeeting/GlobalTravelROI50.pdf"))
##
df1 = combine(groupby(glob_man,:Phase)) do dd
    subdf = unstack(dd,:Treatment,:Poking_Travel_to)
    current_drug = Symbol(subdf[1,:Phase])
    rename!(subdf, current_drug => :Drug)
end
df2 = combine(groupby(df1,[:Phase])) do dd
    wilcoxon(dd,:Drug, :Control; f = x -> mean(skipmissing(x)))
end
Drug_colors!(df2)
plot_wilcoxon(df2)
##
savefig(joinpath(figs_loc,"LabMeeting/GlobalTravelPOKES50.pdf"))
##
df1 = combine(groupby(glob_man,:Phase)) do dd
    subdf = unstack(dd,:Treatment,:AfterLast)
    current_drug = Symbol(subdf[1,:Phase])
    rename!(subdf, current_drug => :Drug)
end
df2 = combine(groupby(df1,[:Phase])) do dd
    wilcoxon(dd,:Drug, :Control; f = x -> mean(skipmissing(x)))
end
Drug_colors!(df2)
plot_wilcoxon(df2)
##
savefig(joinpath(figs_loc,"LabMeeting/GlobalAfterLast50.pdf"))
######################## Selective  Manipulations ###################################
sel_man =  filter(r -> r.Phase in ["SB242084", "Altanserin", "Way_100135"], s)
df1 = combine(groupby(sel_man,:Phase)) do dd
    subdf = unstack(dd,:Treatment,:Num_pokes)
    current_drug = Symbol(subdf[1,:Phase])
    rename!(subdf, current_drug => :Drug)
end
df2 = combine(groupby(df1,[:Phase])) do dd
    wilcoxon(dd,:Drug, :Control; f = x -> mean(skipmissing(x)))
end
Drug_colors!(df2)
plot_wilcoxon(df2)
##
savefig(joinpath(figs_loc,"LabMeeting/SelectiveNumPokes50.pdf"))
##
df1 = combine(groupby(sel_man,:Phase)) do dd
    subdf = unstack(dd,:Treatment,:Trial_Travel_to)
    current_drug = Symbol(subdf[1,:Phase])
    rename!(subdf, current_drug => :Drug)
end
df2 = combine(groupby(df1,[:Phase])) do dd
    wilcoxon(dd,:Drug, :Control; f = x -> mean(skipmissing(x)))
end
Drug_colors!(df2)
plot_wilcoxon(df2)
##
savefig(joinpath(figs_loc,"LabMeeting/SelectiveTravelROI50.pdf"))
##
df1 = combine(groupby(sel_man,:Phase)) do dd
    subdf = unstack(dd,:Treatment,:Poking_Travel_to)
    current_drug = Symbol(subdf[1,:Phase])
    rename!(subdf, current_drug => :Drug)
end
df2 = combine(groupby(df1,[:Phase])) do dd
    wilcoxon(dd,:Drug, :Control; f = x -> mean(skipmissing(x)))
end
Drug_colors!(df2)
plot_wilcoxon(df2)
##
savefig(joinpath(figs_loc,"LabMeeting/SelectiveTravelPOKES50.pdf"))
##
df1 = combine(groupby(sel_man,:Phase)) do dd
    subdf = unstack(dd,:Treatment,:AfterLast)
    current_drug = Symbol(subdf[1,:Phase])
    rename!(subdf, current_drug => :Drug)
end
df2 = combine(groupby(df1,[:Phase])) do dd
    wilcoxon(dd,:Drug, :Control; f = x -> mean(skipmissing(x)))
end
Drug_colors!(df2)
plot_wilcoxon(df2)
##
savefig(joinpath(figs_loc,"LabMeeting/SelectiveAfterLast50.pdf"))
##
x = collect(1:100)
y = -log.(10,x)
plot(x,y)
