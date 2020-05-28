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
    r.Trial_Travel_to < 10 &&
    r.MouseID != "pc7",
    streaks)
s[s.Treatment .== "PreVehicle",:Treatment] .= "Control"
s[s.Treatment .== "Saline",:Treatment] = [o ? "Optogenetic" : "Control" for o in s[s.Treatment .== "Saline",:Stim]]
s[s.Treatment .== "SB242084_opt",:Phase] .=  "SB242084_opt"
s[s.Treatment .== "SB242084_opt",:Treatment] = [o ? "SB242084_opt" : "Control" for o in s[s.Treatment .== "SB242084_opt",:Stim]]
##Webers Law

release = filter(r -> r.Treatment in ["Citalopram","Optogenetic"],s)
WebersLaw(release,:AfterLast,:Treatment)
savefig(joinpath(figs_loc,"WebersLaw/ReleaseManipulation.pdf"))

selective = filter(r -> r.Treatment in ["SB242084","Altanserin"],s)
WebersLaw(selective,:AfterLast,:Treatment)
savefig(joinpath(figs_loc,"WebersLaw/SelectiveManipulation.pdf"))

both = filter(r -> r.Treatment in ["Citalopram","Optogenetic","SB242084","Altanserin"],s)
WebersLaw(both,:AfterLast,:Treatment)
savefig(joinpath(figs_loc,"WebersLaw/EffectiveManipulation.pdf"))

manipulations = filter(r -> r.Treatment != "Control",s)
WebersLaw(manipulations,:AfterLast,:Treatment)
savefig(joinpath(figs_loc,"WebersLaw/AllManipulation.pdf"))

WebersLaw(s,:AfterLast,:Treatment)
savefig(joinpath(figs_loc,"WebersLaw/WithControl.pdf"))
##
Drug_colors!(s)

WebersLaw(s,:AfterLast,:Treatment)

################ 2c opto comparison across days ##############
optopharma = filter(r ->
    r.Phase in ["Optogenetic", "SB242084_opt"], s)
gd = groupby(optopharma,[:MouseID,:Phase,:Stim])
df1 = combine([:Num_pokes,:AfterLast,:Trial_Travel_to] => (n,a,t) ->
    (Num_pokes = mean(n), AfterLast = mean(a), Travel = mean(t))
    ,gd)
df2 = select(df1, Not([:Travel,:Num_pokes]))
df3 = combine(groupby(df2,:Stim)) do dd
    subdf = unstack(dd,:Phase,:AfterLast)
    # current_drug = Symbol(subdf[1,:Phase])
    # rename!(subdf, current_drug => :Drug)
end
open_html_table(df3)
df4 = combine(groupby(df3,[:Stim])) do dd
    wilcoxon(dd,:SB242084_opt, :Optogenetic; f = x -> mean(skipmissing(x)))
end

plot_wilcoxon(df4)
############ Find the exact day before SB manipulation as control ###############
using Dates
stim_drug_days = [Date(2016,07,22),
    Date(2016,07,23),
    Date(2016,07,26),
    Date(2016,07,28),
    Date(2016,07,30),
    Date(2016,08,01)]
optopharma = filter(r ->
    r.Phase in ["Optogenetic", "SB242084_opt"], s)
open_html_table(optopharma)
union(filter(r -> r.Treatment == "SB242084_opt",optopharma).Day)
gd = groupby(optopharma,[:MouseID,:Phase,:Stim])
df1 = combine([:Num_pokes,:AfterLast,:Trial_Travel_to] => (n,a,t) ->
    (Num_pokes = mean(n), AfterLast = mean(a), Travel = mean(t))
    ,gd)
open_html_table(df1)
stim = filter(r -> r.Phase == "Optogenetic" && r.Stim, df1).AfterLast
nostim = filter(r -> r.Phase == "Optogenetic" && !r.Stim, df1).AfterLast
sb_stim = filter(r -> r.Phase == "SB242084_opt" && r.Stim, df1).AfterLast
sb_nostim = filter(r -> r.Phase == "SB242084_opt" && !r.Stim, df1).AfterLast

SignedRankTest(nostim,sb_nostim)
