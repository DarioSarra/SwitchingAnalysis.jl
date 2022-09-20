include.(["filtering.jl","TtestFuns.jl","MixedModelsFuns.jl","PlotsFuns.jl"]);
using Dates
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
## Altogether
list = ["SB242084","Altanserin","Way_100135",
    "Optogenetic","Citalopram","Methysergide",
    "SB242084_opt","Control"]
test_df = filter(r->r.Phase in list && r.Treatment in list,streaks)
# All Random Effects (ARE)
ARE_m0 = fit!(LinearMixedModel(@formula(Num_pokes ~ 1 + Protocol + (1+Protocol|MouseID)),test_df; contrasts))
ARE_m1 = fit!(LinearMixedModel(@formula(Num_pokes ~ 1 + Protocol + Treatment + (1+Protocol+Treatment|MouseID)),test_df; contrasts))
ARE_m2 = fit!(LinearMixedModel(@formula(Num_pokes ~ 1 + Protocol * Treatment + (1+Protocol+Treatment|MouseID)),test_df; contrasts))
MixedModels.likelihoodratiotest(ARE_m0, ARE_m1)
MixedModels.likelihoodratiotest(ARE_m1, ARE_m2)
#=
1 - multiplicative model (protocol and treatment interaction)  is worse than without
2 - interaction model shows
        - NO main effect of Altanserin
        - main effect of Way
        - main effect of SB_Opto
        - no interaction is significant
3 - additive model (no interaction protocol and treatment) shows
        - main effect of Altanserin
        - main effect of Way
        - NO main effect of SB_Opto
=#
## Only Protocol Random effect (PRE)
PRE_m0 = fit!(LinearMixedModel(@formula(Num_pokes ~ 1 + Protocol + (1+Protocol|MouseID)),test_df; contrasts))
PRE_m1 = fit!(LinearMixedModel(@formula(Num_pokes ~ 1 + Protocol + Treatment + (1+Protocol|MouseID)),test_df; contrasts))
PRE_m2 = fit!(LinearMixedModel(@formula(Num_pokes ~ 1 + Protocol * Treatment + (1+Protocol|MouseID)),test_df; contrasts))
MixedModels.likelihoodratiotest(PRE_m0, PRE_m1)
MixedModels.likelihoodratiotest(PRE_m1, PRE_m2)

MixedModels.likelihoodratiotest(PRE_m2, ARE_m2)
#=
1 - multiplicative model (protocol and treatment interaction)  is worse than without
2 - interaction model shows
        - NO main effect of Altanserin
        - main effect of Way
        - main effect of SB_Opto
        - no interaction is significant
3 - additive model (no interaction protocol and treatment) shows
        - everything largely significant
4 - likelihoodratiotest strongly favours all random effects model
=#
## Separate Random Effects (SRE)
list = ["SB242084","Altanserin","Way_100135",
    "Optogenetic","Citalopram","Methysergide",
    "SB242084_opt","Control"]
test_df = filter(r->r.Phase in list && r.Treatment in list,streaks)
# All Random Effects (ARE)
SRE_m0 = fit!(LinearMixedModel(@formula(Num_pokes ~ 1 + Protocol + (1|MouseID)+(Protocol|MouseID)),test_df; contrasts))
SRE_m1 = fit!(LinearMixedModel(@formula(Num_pokes ~ 1 + Protocol + Treatment + (1|MouseID)+(Protocol|MouseID)+(Treatment|MouseID)),test_df; contrasts))
SRE_m2 = fit!(LinearMixedModel(@formula(Num_pokes ~ 1 + Protocol * Treatment + (1|MouseID)+(Protocol|MouseID)+(Treatment|MouseID)),test_df; contrasts))
MixedModels.likelihoodratiotest(SRE_m0, SRE_m1)
MixedModels.likelihoodratiotest(SRE_m1, SRE_m2)
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
eff_feed = effects(design,SRE_m2)
Drug_colors!(eff_feed)
open_html_table(eff_feed)
@df eff_feed plot(:Protocol,:Num_pokes, ribbon = :err,
    group = :Treatment, color = :color, linecolor = :color,
    legend = :outertop, fillalpha = 0.3,
    legendfont = Plots.Font("sans-serif", 4, :hcenter, :vcenter, 0.0, RGB(0.0,0.0,0.0)))


eff_df = copy(test_df[:MouseID,:Protocol,:Treatment,])
effects!(eff_df,SRE_m2)
open_html_table(eff_df[1:100,:])
