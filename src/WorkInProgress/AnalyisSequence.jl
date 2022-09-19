include.(["filtering.jl","TtestFuns.jl","MixedModelsFuns.jl","PlotsFuns.jl"]);
using Dates
gr(size=(600,600), tick_orientation = :out, grid = false,
    linecolor = :black,
    markerstrokecolor = :black,
    thickness_scaling = 2,
    markersize = 6)
contrasts = Dict(:CatProtocol => EffectsCoding(; base="0.5"),
    :Treatment => EffectsCoding(; base="Control"),
    :MouseID => Grouping())
##
union(fullS.Phase)
union(fullS.Treatment)
check = combine(groupby(streaks, :Day), [:Phase, :Treatment] .=> (t -> [union(t)]))
open_html_table(check)
##
#= Full random effect models of Num_pokes shows no significant qualitative effect of any drugs
and significant qualitative effects for all drugs exept Altanserin, Way, SB_Opto
BUILD CONTRAST MATRIX BEFORE CONTINUING=#

list = ["SB242084","Altanserin","Way_100135",
    "Optogenetic","Citalopram","Methysergide",
    "SB242084_opt","Control"]
test_df = filter(r->r.Phase in list && r.Treatment in list,streaks)
m0 = fit!(LinearMixedModel(@formula(Num_pokes ~ 1 + Protocol * Treatment + (1|MouseID+Treatment)),test_df; contrasts))
m1 = fit!(LinearMixedModel(@formula(Num_pokes ~ 1 + Protocol + Treatment + (1+Protocol+Treatment|MouseID)),test_df; contrasts))
m2 = fit!(LinearMixedModel(@formula(Num_pokes ~ 1 + Protocol * Treatment + (1+Protocol+Treatment|MouseID)),test_df; contrasts))
MixedModels.likelihoodratiotest(m1, m2)
##
al_m0 = fit!(LinearMixedModel(@formula(AfterLast ~ 1 + Protocol * Treatment + (1|MouseID)),test_df))
al_m1 = fit!(LinearMixedModel(@formula(AfterLast ~ 1 + Protocol * Treatment + (1+Protocol|MouseID)),test_df))
al_m2 = fit!(LinearMixedModel(@formula(AfterLast ~ 1 + Protocol * Treatment + (1+Protocol+Treatment|MouseID)),test_df))
## Prew at leaving per protocol
plot_perprotocol(streaks, :Leaving_NextPrew, "Control")
    xlabel!("Trial type")
    yaxis!(yticks = (0:0.1:0.4),  ylabel = "Reward probability", ylims = (0.0,0.4))
    plot!([1,3],[0.33,0.33])
    annotate!(2,0.36,Plots.text("n.s.",16))
savefig(joinpath(figs_loc,"Paper","Fig2","B-Prew_Protocol.pdf"))
test_perprotocol(streaks, :Leaving_NextPrew, "Control")
##
stimbound_f = @formula(AfterLast ~ 1 + Num_Rewards  + Age + (1+Num_Rewards|MouseID));
stimbound_m = fit(MixedModel,stimbound_f, Age_s)
simple_age_coeff = DataFrame(only(raneftables(stimbound_m)))
rename!(simple_age_coeff, Symbol("(Intercept)") => :Intercept, :Num_Rewards => :Res_NumRewards)
simple_age_coeff[!,:Coef_NumRewards] = simple_age_coeff.Res_NumRewards .+ stimbound_m.β[2]
simple_age_coeff[!,:Age] = [x in dario_youngs ? "Juveniles" : "Adults" for x in simple_age_coeff.MouseID]
transform!(groupby(simple_age_coeff,:Age), :Intercept =>
    (x-> round.(accumulate(+, repeat([0.02],length(x)); init = 0), digits =2)) => :Shift)
transform!(simple_age_coeff, [:Shift,:Age] =>
    ((p,a) -> round.(p .+ [x == "Juveniles" ? 1 : 2 for x in a], digits = 2)) => :Pos)
##
list = ["SB242084","Altanserin","Control"]
test_sel = filter(r->r.Phase in list &&
    r.Treatment in list,streaks)
union(streaks.Phase)
Drug_colors!(test_sel)
## Prew at leaving
plot_drugs(test_sel, :Leaving_NextPrew)
    ylabel!("Reward probability")
prew_sel_m1,prew_sel_m2, prew_sel_m3, prew_sel_l1, prew_sel_l2 =
    test_drugs(test_sel,:Leaving_NextPrew)
##
m = prew_sel_m3
coeff = DataFrame(only(raneftables(m)))
rename!(coeff, Symbol("(Intercept)") => :Intercept)
println(propertynames(coeff))
## Num pokes
plot_drugs(test_sel, :Num_pokes)
    ylabel!("Pokes per trial")
pokes_sel_m1,pokes_sel_m2, pokes_sel_m3, pokes_sel_l1, pokes_sel_l2 =
    test_drugs(test_sel,:Num_pokes)
## AfterLast
plot_drugs(test_sel, :AfterLast)
    ylabel!("Pokes after last reward")
after_sel_m1,after_sel_m2, after_sel_m3, after_sel_l1, after_sel_l2 =
    test_drugs(test_sel,:AfterLast)
## T test Reward number
tt = Ttest_drugs(test_sel, :Num_Rewards)
plot_Ttest(test_sel, :Num_Rewards)
    ylabel!("Delta number of reward")
    ylims!(-0.6,0.32)
    annotate!([(0.5,0.3,Plots.text("n.s.",16)), (1.5,0.28,Plots.text("*",16))])
##
tt = Ttest_drugs(test_sel, :Num_pokes)
tt = Ttest_drugs(test_sel, :AfterLast)
plot_Ttest(test_sel, :Num_pokes)
    ylabel!("Delta pokes after last reward")
    # ylims!(-0.6,0.32)
    annotate!([(0.5,0.3,Plots.text("n.s.",16)), (1.5,0.28,Plots.text("*",16))])
