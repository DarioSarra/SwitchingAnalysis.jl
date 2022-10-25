include.(["filtering.jl","TtestFuns.jl","MixedModelsFuns.jl","PlotsFuns.jl"]);
using Dates, Revise
gr(size=(600,600), tick_orientation = :out, grid = false,
    linecolor = :black,
    markerstrokecolor = :black,
    thickness_scaling = 2,
    markersize = 6)
## Selective
list = ["SB242084","Altanserin","Control", "Way_100135"]
list = ["SB242084","Altanserin","Control", "Methysergide"]

test_sel = filter(r->r.Phase in list &&
    r.Treatment in list,streaks)
union(streaks.Phase)
Drug_colors!(test_sel)
drug_colors
## Prew at leaving
plot_drugs(test_sel, :Leaving_NextPrew)
    ylabel!("Reward probability")
prew_sel_m1,prew_sel_m2, prew_sel_m3, prew_sel_l1, prew_sel_l2 =
    test_drugs(test_sel,:Leaving_NextPrew)
savefig(joinpath(figs_loc,"Meeting","Sel_RewP.pdf"))
## Num pokes
plot_drugs(test_sel, :Num_pokes)
    ylabel!("Pokes per trial")
pokes_sel_m1,pokes_sel_m2, pokes_sel_m3, pokes_sel_l1, pokes_sel_l2 =
    test_drugs(test_sel,:Num_pokes)
savefig(joinpath(figs_loc,"Meeting","Sel_Nump.pdf"))
## AfterLast
plot_drugs(test_sel, :AfterLast)
    ylabel!("Pokes after last reward")
after_sel_m1,after_sel_m2, after_sel_m3, after_sel_l1, after_sel_l2 =
    test_drugs(test_sel,:AfterLast)
savefig(joinpath(figs_loc,"Meeting","Sel_AfterL.pdf"))
## T test Reward number
tt = Ttest_drugs(test_sel, :Num_Rewards)
resplt, resdf = plot_Ttest(test_sel, :Num_Rewards, ylabel = "Delta # of reward", ylims = (-0.6,0.42),
    xlims = (0,3), xrotation = 15)
    resplt
savefig(joinpath(figs_loc,"Meeting","Sel_NumR.pdf"))
##Travel
resplt, resdf = plot_Ttest(test_sel, :Trial_Travel_to, ylabel = "Travel time")
    resplt
savefig(joinpath(figs_loc,"Meeting","Sel_Travel_comp.pdf"))
##Travel
resplt, resdf = plot_Ttest(test_sel, :ROI_Leaving_Time, ylabel = "Travel time")
    resplt
savefig(joinpath(figs_loc,"Meeting","Sel_ROI_comp.pdf"))
test_sel.ROI_Leaving_Time
##
resplt, resdf = plot_Ttest(test_sel, :Num_pokes, ylabel = "# Pokes",
    xlims = (0,3), xrotation = 15)
    resplt
savefig(joinpath(figs_loc,"Meeting","Mix_NP_comp.pdf"))
##
resplt, resdf = plot_Ttest(test_sel, :AfterLast, ylabel = "AfterLast",
    xlims = (0,3), xrotation = 15)
    resplt
savefig(joinpath(figs_loc,"Meeting","Sel_AL_comp.pdf"))
## Global
list = ["Optogenetic","Citalopram", "Control", "Methysergide", "SB242084_opt"]
test_glo = filter(r->r.Phase in list &&
    r.Treatment in list,streaks)
Drug_colors!(test_glo)
## Prew at leaving
plot_drugs(test_glo, :Leaving_NextPrew)
    ylabel!("Reward probability")
prew_sel_m1,prew_sel_m2, prew_sel_m3, prew_sel_l1, prew_sel_l2 =
    test_drugs(test_glo,:Leaving_NextPrew)
savefig(joinpath(figs_loc,"Meeting","Glo_RewP.pdf"))
## Num pokes
plot_drugs(test_glo, :Num_pokes)
    ylabel!("Pokes per trial")
pokes_sel_m1,pokes_sel_m2, pokes_sel_m3, pokes_sel_l1, pokes_sel_l2 =
    test_drugs(test_glo,:Num_pokes)
savefig(joinpath(figs_loc,"Meeting","Glo_Nump.pdf"))
## AfterLast
plot_drugs(test_glo, :AfterLast)
    ylabel!("Pokes after last reward")
after_sel_m1,after_sel_m2, after_sel_m3, after_sel_l1, after_sel_l2 =
    test_drugs(test_glo,:AfterLast)
savefig(joinpath(figs_loc,"Meeting","Glo_AfterL.pdf"))
## T test Reward number
tt = Ttest_drugs(test_glo, :Num_Rewards)
resplt, resdf = plot_Ttest(test_glo, :Num_Rewards, ylabel = "Delta # of reward", ylims = (-0.6,0.42),
    xlims = (0,4), xrotation = 15)
    resplt
savefig(joinpath(figs_loc,"Meeting","Glo_NumR.pdf"))
##Travel
resplt, resdf = plot_Ttest(test_glo, :ROI_Leaving_Time, ylabel = "Travel time",
    xlims = (0,4), xrotation = 15)
    resplt
savefig(joinpath(figs_loc,"Meeting","Glo_ROI_comp.pdf"))

##Travel
resplt, resdf = plot_Ttest(test_glo, :Trial_Travel_to, ylabel = "Travel time",
    xlims = (0,4), xrotation = 15)
    resplt
    resdf
savefig(joinpath(figs_loc,"Meeting","Glo_Travel_comp.pdf"))
##
resplt, resdf = plot_Ttest(test_glo, :Num_pokes, ylabel = "# Pokes",
    xlims = (0,4), xrotation = 15)
    resplt
    resdf
savefig(joinpath(figs_loc,"Meeting","Glo_NP_comp.pdf"))
##
resplt, resdf = plot_Ttest(test_glo, :AfterLast, ylabel = "AfterLast",
    xlims = (0,4), xrotation = 15)
    resplt
    resdf
savefig(joinpath(figs_loc,"Meeting","Glo_AL_comp.pdf"))
