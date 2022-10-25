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
## Expanded Separate Random Effects (SRE)
#=
1 - multiplicative model (protocol and treatment interaction)  is worse than without
2 - interaction model shows
        - main effect of Altanserin
        - main effect of Way
        - no main effect of SB_Opto
        - SB_opto has a significant interaction with protocol
3 - additive model (no interaction protocol and treatment) shows
        - main effect of Altanserin
        - main effect of Way
        - NO main effect of SB_Opto
=#
list = ["SB242084","Altanserin","Way_100135",
    "Optogenetic","Citalopram","Methysergide",
    "SB242084_opt","Control"]
test_df = filter(r->r.Phase in list && r.Treatment in list,streaks)
# Separate Random Effects (SRE)
ESRE_m0 = fit!(LinearMixedModel(@formula(Num_pokes ~ 1 + Protocol +
    (1|MouseID)+(Protocol|MouseID)),test_df; contrasts))
ESRE_m1 = fit!(LinearMixedModel(@formula(Num_pokes ~ 1 + Protocol + Treatment +
    (1|MouseID)+(Protocol|MouseID)+(Treatment|MouseID)),
    test_df; contrasts))
ESRE_m2 = fit!(LinearMixedModel(@formula(Num_pokes ~ 1 + Protocol * Treatment +
    (1|MouseID)+(Protocol|MouseID)+(Treatment|MouseID) + (Protocol&Treatment|MouseID)),
    test_df; contrasts))
MixedModels.likelihoodratiotest(ESRE_m0, ESRE_m1)
MixedModels.likelihoodratiotest(ESRE_m1, ESRE_m2)
## EFFECTS plots
using Effects
#= there are two ways to make it work:
- 1 is to compute the prediction for a set of values. This uses effect(Dict,Model)
    the Dict has to have keys corresponding to the model factors and the entry is a vector of value of interest
    vectors don't have to be the same length. effect will automatically cross the values
-2 effect!(DataFrame,Model) overwrite the column you want to predict directly on a copy of the DataFrame
=#
unique(test_df.Treatment)
design = Dict(:Treatment => unique(test_df.Treatment),
        :Protocol => unique(test_df.Protocol))
eff_feed = effects(design,ESRE_m2)
Drug_colors!(eff_feed)
# open_html_table(eff_feed)
selective = ["Altanserin", "SB242084","Way_100135","Control"]
general = ["Citalopram", "Optogenetic","SB242084_opt","Methysergide", "Control"]
@df filter(r -> r.Treatment in selective, eff_feed) plot(:Protocol,:Num_pokes, ribbon = :err,
    group = :Treatment, color = :color, linecolor = :color,
    xticks = ([0.5,0.75,1.0], ["Poor", "Medium","Rich"]),
    ylabel = "Number of pokes", ylims = (0,16),
    legend = :outertop, fillalpha = 0.3,
    legendfont = Plots.Font("sans-serif", 4, :hcenter, :vcenter, 0.0, RGB(0.0,0.0,0.0)))

@df filter(r -> r.Treatment in general, eff_feed) plot(:Protocol,:Num_pokes, ribbon = :err,
    group = :Treatment, color = :color, linecolor = :color,
    legend = :outertop, fillalpha = 0.3,
    xticks = ([0.5,0.75,1.0], ["Poor", "Medium","Rich"]),
    ylabel = "Number of pokes", ylims = (0,16),
    legendfont = Plots.Font("sans-serif", 4, :hcenter, :vcenter, 0.0, RGB(0.0,0.0,0.0)))

# second method with df copy
eff_df = copy(test_df[:MouseID,:Protocol,:Treatment,])
effects!(eff_df,ESRE_m2)
open_html_table(eff_df[1:100,:])
## Model estimates Plots
np_coef = DataFrame(Variable = replace.(fixefnames(ESRE_m2),"(centered: 0.75)"=>"", "Treatment: "=>""),
    Coef = coef(ESRE_m2),
    Error = stderror(ESRE_m2))

np_coef[!,:Values] = [contains(r.Variable, "Protocol") ?
    contains(r.Variable, "&") ?
        (r.Coef + np_coef[2,:Coef]) * 0.75 + np_coef[1,:Coef] :
        r.Coef * 0.75 + np_coef[1,:Coef] :
        contains(r.Variable,"Intercept") ?
            r.Coef :
            r.Coef + np_coef[1,:Coef] + np_coef[2,:Coef] * 0.75
    for r in eachrow(np_coef)]
np_coef = np_coef[2:end,:]
np_coef[!,:Variables] = [n == "(Intercept)" ? n : n == "Protocol" ? " Baseline" :
    contains(n, "Protocol") ?
    replace(n,"Protocol & " => "") * " Mult." : n * " Add." for n in np_coef.Variable]
sort!(np_coef,:Variables)
np_coef[!,:Color] = [get(drug_colors,replace(v," Mult." => "", " Add." => ""), RGB(0.0,0.0,0.0)) for v in np_coef.Variables]
# open_html_table(np_coef)
@df np_coef[1:end,:] scatter(:Variables, :Values, yerr = :Error,
    xrotation = 45, size = (600,1000), color = :Color,
    ylabel = "Pokes number model's  prediction", legend = false)
# hline!([np_coef[1,:Values]+np_coef[1,:Error]], label = "")
# hline!([np_coef[1,:Values]-np_coef[1,:Error]], label = "")
hspan!([np_coef[1,:Values]+np_coef[1,:Error], np_coef[1,:Values]-np_coef[1,:Error]], fillalpha = 0.3, color = :grey)
savefig(joinpath(figs_loc,"MixedModel","model_estimated_effects.png"))
## Beta coefficients
np_raneff = DataFrame(only(raneftables(ESRE_m2)))
open_html_table(np_raneff)

np_feff = DataFrame(;zip(Symbol.(fixefnames(ESRE_m2)), coef(ESRE_m2))...)
np_mbetas = DataFrame(MouseID = np_raneff.MouseID)
for n  in propertynames(np_feff)
    np_mbetas[!,n] = np_raneff[:,n] .+ np_feff[1,n]
end
size(np_mbetas)
open_html_table(np_mbetas)


fixefnames(ESRE_m2)[10:16]
interaction_betas = np_mbetas[:,[:MouseID,Symbol("Protocol(centered: 0.75)"),Symbol.(fixefnames(ESRE_m2)[10:16])...]]

interaction_betas = np_mbetas[:,[:MouseID,Symbol("Protocol(centered: 0.75)"), Symbol("Protocol(centered: 0.75) & Treatment: Optogenetic")]]
interaction_betas[:,3] = interaction_betas[:,2] .+ interaction_betas[:,3]
@df stack(interaction_betas,2:3) scatter(:variable, :value,
    xticks = ([2,3],["Protocol", "Protocol&Opto"]))



plt_np_mbetas = stack(np_mbetas,2:17)
@df plt_np_mbetas scatter(:variable, :value,
    markersize = 2, xrotation = 90, size = (1200,2500))
f = filter(r-> r.variable == "Protocol(centered: 0.75) & Treatment: Optogenetic", plt_np_mbetas)
@df f scatter(:variable, :value,
    markersize = 2, xrotation = 90, size = (600,1500))


predict(ESRE_m2)
## By Treatment
m = @formula(Num_pokes ~ 1 + Protocol * Treatment +
    (1|MouseID)+(Protocol|MouseID)+(Treatment|MouseID) + (Protocol&Treatment|MouseID))
Alt = filter(r -> r.Phase == "Altanserin" && r.Treatment != "None", streaks)
SB = filter(r -> r.Phase == "SB242084" && r.Treatment != "None", streaks)
Way = filter(r -> r.Phase == "Way_100135" && r.Treatment != "None", streaks)
Cit = filter(r -> r.Phase == "Citalopram" && r.Treatment != "None", streaks)
Opto = filter(r -> r.Phase == "Optogenetic" && r.Treatment != "None", streaks)
Met = filter(r -> r.Phase == "Methysergide" && r.Treatment != "None", streaks)
SBOpt = filter(r -> r.Phase == "SB242084_opt" && r.Treatment != "None", streaks)
##
Alt_plt_np, Alt_eff_np, Alt_mod_np = plot_effects(Alt,:Num_pokes,:Protocol,:Treatment,
    :MouseID,contrasts; ylims = (0,17), legend = :bottomright,
    xticks = ([0.5,0.75,1.0], ["Poor", "Medium", "Rich"]), xlims = (0.3,1.2),
    ylabel = "Predicted # Pokes", left_margin = -20px, bottom_margin = -20px,
    markersize = 5, markeralpha = 0.6, markerstrokewidth = 0.4)
Alt_plt_np
savefig(joinpath(figs_loc,"Ongoing2022","Alt_Eff_NumPokes.pdf"))
##
SB_plt_np, SB_eff_np, SB_mod_np = plot_effects(SB,:Num_pokes,:Protocol,:Treatment,
    :MouseID,contrasts; ylims = (0,17), legend = :bottomright,
    xticks = ([0.5,0.75,1.0], ["Poor", "Medium", "Rich"]), xlims = (0.3,1.2),
    ylabel = "Predicted # Pokes", left_margin = -20px, bottom_margin = -20px,
    markersize = 5, markeralpha = 0.6, markerstrokewidth = 0.4)
SB_plt_np
savefig(joinpath(figs_loc,"Ongoing2022","SB_Eff_NumPokes.pdf"))
##
Way_plt_np, Way_eff_np, Way_mod_np = plot_effects(Way,:Num_pokes,:Protocol,:Treatment,
    :MouseID,contrasts; ylims = (0,17), legend = :bottomright,
    xticks = ([0.5,0.75,1.0], ["Poor", "Medium", "Rich"]), xlims = (0.3,1.2),
    ylabel = "Predicted # Pokes", left_margin = -20px, bottom_margin = -20px,
    mmarkersize = 5, markeralpha = 0.6, markerstrokewidth = 0.4)
Way_plt_np
savefig(joinpath(figs_loc,"Ongoing2022","Way_Eff_NumPokes.pdf"))
##
Opto_plt_np, Opto_eff_np, Opto_mod_np = plot_effects(Opto,:Num_pokes,:Protocol,:Treatment,
    :MouseID,contrasts; ylims = (0,17), legend = :bottomright,
    xticks = ([0.5,0.75,1.0], ["Poor", "Medium", "Rich"]), xlims = (0.3,1.2),
    ylabel = "Predicted # Pokes", left_margin = -20px, bottom_margin = -20px,
    markersize = 5, markeralpha = 0.6, markerstrokewidth = 0.4)
Opto_plt_np
savefig(joinpath(figs_loc,"Ongoing2022","Opto_Eff_NumPokes.pdf"))
##
Cit_plt_np, Cit_eff_np, Cit_mod_np = plot_effects(Cit,:Num_pokes,:Protocol,:Treatment,
    :MouseID,contrasts; ylims = (0,17), legend = :bottomright,
    xticks = ([0.5,0.75,1.0], ["Poor", "Medium", "Rich"]), xlims = (0.3,1.2),
    ylabel = "Predicted # Pokes", left_margin = -20px, bottom_margin = -20px,
    markersize = 5, markeralpha = 0.6, markerstrokewidth = 0.4)
Cit_plt_np
savefig(joinpath(figs_loc,"Ongoing2022","Cit_Eff_NumPokes.pdf"))
##
Met_plt_np, Met_eff_np, Met_mod_np = plot_effects(Met,:Num_pokes,:Protocol,:Treatment,
    :MouseID,contrasts; ylims = (0,17), legend = :bottomright,
    xticks = ([0.5,0.75,1.0], ["Poor", "Medium", "Rich"]), xlims = (0.3,1.2),
    ylabel = "Predicted # Pokes", left_margin = -20px, bottom_margin = -20px,
    markersize = 5, markeralpha = 0.6, markerstrokewidth = 0.4)
Met_plt_np
savefig(joinpath(figs_loc,"Ongoing2022","Met_Eff_NumPokes.pdf"))
##
SBOpt_plt_np, SBOpt_eff_np, SBOpt_mod_np = plot_effects(SBOpt,:Num_pokes,:Protocol,:Treatment,
    :MouseID,contrasts; ylims = (0,17), legend = :bottomright,
    xticks = ([0.5,0.75,1.0], ["Poor", "Medium", "Rich"]), xlims = (0.3,1.2),
    ylabel = "Predicted # Pokes", left_margin = -20px, bottom_margin = -20px,
    markersize = 5, markeralpha = 0.6, markerstrokewidth = 0.4)
SBOpt_plt_np
savefig(joinpath(figs_loc,"Ongoing2022","SBOpt_Eff_NumPokes.pdf"))
##
plot_model_estimates(Alt_mod_np)
savefig(joinpath(figs_loc,"Ongoing2022","Alt_Coeff_NumPokes.pdf"))
plot_model_estimates(SB_mod_np)
savefig(joinpath(figs_loc,"Ongoing2022","SB_Coeff_NumPokes.pdf"))
plot_model_estimates(Way_mod_np)
savefig(joinpath(figs_loc,"Ongoing2022","Way_Coeff_NumPokes.pdf"))
plot_model_estimates(Opto_mod_np)
savefig(joinpath(figs_loc,"Ongoing2022","Opto_Coeff_NumPokes.pdf"))
plot_model_estimates(Cit_mod_np)
savefig(joinpath(figs_loc,"Ongoing2022","Cit_Coeff_NumPokes.pdf"))
plot_model_estimates(Met_mod_np)
savefig(joinpath(figs_loc,"Ongoing2022","Met_Coeff_NumPokes.pdf"))
plot_model_estimates(SBOpt_mod_np)
savefig(joinpath(figs_loc,"Ongoing2022","SBOpt_Coeff_NumPokes.pdf"))
