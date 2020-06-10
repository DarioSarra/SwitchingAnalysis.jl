include("filtering.jl");
##
odc = ODC(pokes)
@df filter(r -> r.PokeDuration < 4,odc) density(:PokeDuration,group = :Reward)
plot!(repeat([0.43],2), [0,8])
plot!(repeat([0.7],2), [0,8])
odc[!,:ClearDuration] = [r.Reward ? r.PokeDuration > 0.7 : r.PokeDuration < 0.4 for r in eachrow(odc)]
list = ["PreVehicle",
    "Altanserin",
    "SB242084",
    "Way_100135",
    "Methysergide",
    "Citalopram",
    "SB242084_opt",
    "Saline"]

filter!(r -> r.Treatment in list &&
    !ismissing(r.Pre_Interpoke) &&
    r.Pre_Interpoke < 0.5 &&
    r.ClearDuration &&
    r.Trial < 61 &&
    r.MouseID != "d5" &&
    r.MouseID != "pc7",# ["pc1","pc2","pc3","pc4","pc5","pc6","pc8","pc9","pc10"],
    odc)

odc[odc.Treatment .== "PreVehicle",:Treatment] .= "Control"
odc[odc.Treatment .== "Saline",:Treatment] = [o ? "Optogenetic" : "Control" for o in odc[odc.Treatment .== "Saline",:Stim]]
odc[odc.Treatment .== "SB242084_opt",:Phase] .=  "SB242084_opt"
odc[odc.Treatment .== "SB242084_opt",:Treatment] = [o ? "SB242084_opt" : "Control" for o in odc[odc.Treatment .== "SB242084_opt",:Stim]]


df1 = filter(r -> !r.Reward &&
    r.ExpDay > 3 &&
    !ismissing(r.PokeFromLastRew) &&
    0 < r.PokeFromLastRew &&
    !ismissing(r.ODC) &&
    r.Treatment in ["Control","Citalopram", "Optogenetic", "Altanserin","SB242084"] &&
    !in(r.Phase,["Methysergide", "Way_100135","SB242084_opt"]) ,odc)

categorical!(df1,[:MouseID,:Treatment,:Phase])

levels!(df1.Treatment, ["Control",
    "Citalopram",
    "Optogenetic",
    "Altanserin",
    "SB242084"])

transform!(groupby(df1,[:MouseID,:Phase,:Treatment]), :ODC => mean => :ODC_mean)
df1[!,:NODC] = df1.ODC ./ df1.ODC_mean
transform!(groupby(df1,[:MouseID,:Phase,:Treatment]), :NODC => binquantile => :QODC)
df1[!,:Leave] = [r == 0 for r in df1.PokeFromLeaving]
## Prepare 2 separate dataframes for pharma and opto
# pharma
################# from last reward
odc_fromlast = @formula(QODC ~ PokeFromLastRew * Treatment + (1|MouseID))
filtered = filter(r -> r.PokeFromLastRew < 10, df1)
cit = filter(r -> r.Phase == "Citalopram", filtered)
opto = filter(r -> r.Phase == "Optogenetic", filtered)
alt = filter(r -> r.Phase == "Altanserin", filtered)
sb = filter(r -> r.Phase == "SB242084", filtered)
cit_fromlast = fit!(LinearMixedModel(odc_fromlast,cit))
sb_fromlast = fit!(LinearMixedModel(odc_fromlast,sb))
opt_fromlast = fit!(LinearMixedModel(odc_fromlast,opto))
alt_fromlast = fit!(LinearMixedModel(odc_fromlast,alt))
plot_QODC(filtered,:PokeFromLastRew)
savefig(joinpath(figs_loc,"ODC","ODC_from_last","QODC_lastrew.pdf"))
########################## from leaving
odc_fromleave = @formula(QODC ~ PokeFromLeaving * Treatment + (1|MouseID))
filtered = filter(r -> r.PokeFromLeaving < 5, df1)
cit = filter(r -> r.Phase == "Citalopram", filtered)
opto = filter(r -> r.Phase == "Optogenetic", filtered)
alt = filter(r -> r.Phase == "Altanserin", filtered)
sb = filter(r -> r.Phase == "SB242084", filtered)
# cit_fromleave = fit!(LinearMixedModel(odc_fromleave,cit))
# sb_fromleave = fit!(LinearMixedModel(odc_fromleave,sb))
# opt_fromleave = fit!(LinearMixedModel(odc_fromleave,opto))
# alt_fromleave = fit!(LinearMixedModel(odc_fromleave,alt))

cit_fromleave = GeneralizedLinearMixedModel(odc_fromleave,cit,Poisson())
sb_fromleave = GeneralizedLinearMixedModel(odc_fromleave,sb,Poisson())
opt_fromleave = GeneralizedLinearMixedModel(odc_fromleave,opto,Poisson())
alt_fromleave = GeneralizedLinearMixedModel(odc_fromleave,alt,Poisson())
plot_QODC(filtered,:PokeFromLeaving; xflip = true)
savefig(joinpath(figs_loc,"ODC","ODC_from_leaving","QODC_leaving.pdf"))
##
allignment = :PokeFromLeaving
dd = filtered
gd1 = groupby(dd,[:Phase,:MouseID,allignment,:Treatment])
dd1 = combine(gd1, :QODC => mean)
gd2 = groupby(dd1,[:Phase,allignment,:Treatment])
dd2 = combine(gd2, :QODC_mean => mean => :QODC_mean, :QODC_mean => sem => :QODC_sem)
plts = []
Drug_colors!(dd2)
combine(groupby(dd2,:Phase)) do dd
    p = @df dd scatter(cols(allignment), :QODC_mean, yerror = :QODC_sem,
    group = :Treatment,xflip =true, legend = :bottomleft, color = :color)
    push!(plts,p)
end
plot(plts...)

#########
union(pharma.MouseID)
union(pharma.Treatment)
scatter(pharma.Leave,pharma.PokeFromLastRew)
pharma_leave = countmap(pharma[pharma.Leave,:PokeFromLastRew])
pharma_stay = countmap(pharma[.!pharma.Leave,:PokeFromLastRew])
scatter(collect(keys(pharma_leave)),collect(values(pharma_leave))./sum(collect(values(d))))
scatter!(collect(keys(pharma_stay)),collect(values(pharma_stay))./sum(collect(values(d))))
#opto
opto = filter(r -> r.Phase == "Optogenetic", df1)
union(opto.MouseID)
union(opto.Treatment)
scatter(opto.Leave,opto.PokeFromLastRew)
opto_leave = countmap(opto[opto.Leave,:PokeFromLastRew])
opto_stay = countmap(opto[.!opto.Leave,:PokeFromLastRew])
scatter(collect(keys(opto_leave)),collect(values(opto_leave))./sum(collect(values(d))))
scatter!(collect(keys(opto_stay)),collect(values(opto_stay))./sum(collect(values(d))))
############################ pharma ######################################
basic_pharma = @formula(Leave ~ Poke_within_Trial + (1|MouseID));
odc_pharma = @formula(Leave ~ ODC * Poke_within_Trial + (1|MouseID));
full_pharma = @formula(Leave ~ ODC * Poke_within_Trial * Treatment  + (1|MouseID));
fBP = GeneralizedLinearMixedModel(basic_pharma, pharma,Bernoulli())
fOP = GeneralizedLinearMixedModel(odc_pharma, pharma,Bernoulli())
fFP = GeneralizedLinearMixedModel(full_pharma, pharma,Bernoulli())
AICcTest(fOP,fBP)
LoglikelihoodRatioTest(fBP,fOP)
AICcTest(fFP,fOP)
LoglikelihoodRatioTest(fOP,fFP)
############################ opto ######################################
basic_opto = @formula(Leave ~ Poke_within_Trial + (1|MouseID));
odc_opto = @formula(Leave ~ ODC * Poke_within_Trial + (1|MouseID));
full_opto = @formula(Leave ~ ODC * Poke_within_Trial * Treatment  + (1|MouseID));
fBO = GeneralizedLinearMixedModel(basic_opto, opto,Bernoulli())
fOO = GeneralizedLinearMixedModel(odc_opto, opto,Bernoulli())
fFO = GeneralizedLinearMixedModel(full_opto, opto,Bernoulli())
AICcTest(fOO,fBO)
LoglikelihoodRatioTest(fBO,fOO)
AICcTest(fFO,fOO)
LoglikelihoodRatioTest(fOO,fFO)
############################ pharma ######################################
basic_pharma = @formula(Leave ~ PokeFromLastRew + (1|MouseID));
odc_pharma = @formula(Leave ~ ODC * PokeFromLastRew + (1|MouseID));
full_pharma = @formula(Leave ~ ODC * PokeFromLastRew * Treatment  + (1|MouseID));
alt_pharma = @formula(Leave ~ PokeFromLastRew + ODC * Treatment  + (1|MouseID));
fBP = GeneralizedLinearMixedModel(basic_pharma, pharma,Bernoulli())
fOP = GeneralizedLinearMixedModel(odc_pharma, pharma,Bernoulli())
fFP = GeneralizedLinearMixedModel(full_pharma, pharma,Bernoulli())
f_alt = GeneralizedLinearMixedModel(alt_pharma,pharma,Bernoulli())
AICcTest(fOP,fBP)
LoglikelihoodRatioTest(fBP,fOP)
AICcTest(fFP,fOP)
LoglikelihoodRatioTest(fOP,fFP)
############################ opto ######################################
basic_opto = @formula(Leave ~ Poke_within_Trial + (1|MouseID));
odc_opto = @formula(Leave ~ ODC * Poke_within_Trial + (1|MouseID));
full_opto = @formula(Leave ~ ODC * Poke_within_Trial * Treatment  + (1|MouseID));
fBO = GeneralizedLinearMixedModel(basic_opto, opto,Bernoulli())
fOO = GeneralizedLinearMixedModel(odc_opto, opto,Bernoulli())
fFO = GeneralizedLinearMixedModel(full_opto, opto,Bernoulli())
AICcTest(fOO,fBO)
LoglikelihoodRatioTest(fBO,fOO)
AICcTest(fFO,fOO)
LoglikelihoodRatioTest(fOO,fFO)
##############################################################################
predict(fFP)
# afterlast
# afterlast + treatment
# afteralst + treatment + ODC
# plot histogram from data p leaving over binned duty cycle
# heatmap pleaving xaxis pokesafterlast yaxis binned duty cycle
##############################################################################
cit = filter(r -> r.Phase == "Citalopram", pharma)
treat = @formula(Leave ~ PokeFromLastRew + Treatment  + (1|MouseID));
with_odc = @formula(Leave ~ PokeFromLastRew + Treatment + ODC  + (1|MouseID));
duty = @formula(Leave ~  Treatment + ODC  + (1|MouseID));
cit_treat = GeneralizedLinearMixedModel(treat, cit,Bernoulli())
cit_odc = GeneralizedLinearMixedModel(with_odc, cit,Bernoulli())
cit_duty = GeneralizedLinearMixedModel(duty, cit,Bernoulli())
opt_treat = GeneralizedLinearMixedModel(treat, opto,Bernoulli())
opt_odc = GeneralizedLinearMixedModel(with_odc, opto,Bernoulli())
opt_duty = GeneralizedLinearMixedModel(duty, opto,Bernoulli())

##############################################################################
# ODC ~ afterlast * Treatment
# ODC ~ poke_toleave * treatment this shoud be opto
odc_after = @formula(ODC ~ PokeFromLastRew  * Treatment + (1|MouseID))
cit_after = fit!(LinearMixedModel(odc_after,cit))
opto_after = fit!(LinearMixedModel(odc_after,opto))
union(cit.Treatment)
cit2  = filter(r -> r.PokeFromLastRew < 6, cit)
cit2_after = fit!(LinearMixedModel(odc_after,cit2))

ll =-2(loglikelihood(fOP) - loglikelihood(fFP))

# check odc and pokeafterlastrew weight
open_html_table(df1[1:200,[:Poke,:Trial,:PokeFromLastRew,:PokeFromLeaving,:Leave]])
scatter(df1.Leave,df1.PokeFromLastRew)
m_basic = @formula(Leave ~ PokeFromLastRew + (1|MouseID));
f_basic = GeneralizedLinearMixedModel(m_basic, df1, Bernoulli());
m_odc = @formula(Leave ~ ODC * PokeFromLastRew + (1|MouseID));
f_odc = GeneralizedLinearMixedModel(m_basic, df1, Bernoulli());
AICcTest(f_odc, f_basic)
# full model
m_full = @formula(Leave ~ ODC * PokeFromLastRew * Treatment  + (1|MouseID));
f_full = GeneralizedLinearMixedModel(m_full, df1, Bernoulli());
# simplified model without significant simple factors
m_a1 = @formula(Leave ~ ODC + PokeFromLastRew +  Treatment  + (1|MouseID));
f_without_interaction = GeneralizedLinearMixedModel(m_a1, df1, Bernoulli());
m_a2 = @formula(Leave ~ ODC + PokeFromLastRew + ODC & PokeFromLastRew + ODC & Treatment & PokeFromLastRew  + (1|MouseID));
f_fromlast_interaction = GeneralizedLinearMixedModel(m_a2, df1, Bernoulli());
AICcTest(f_full,f_without_interaction)
AICcTest(f_full,f_fromlast_interaction)
## Plot regression
df2 = combine(groupby(df1,[:Treatment])) do dd
    summarize(dd,:PokeFromLastRew, :ODC)
end
Drug_colors!(df2)
@df filter(r -> r.Treatment in ["Control", "Citalopram"], df2) scatter(:Xaxis,:Mean, group = :Treatment, color = :color, markersize = 7)
@df filter(r -> r.Treatment in ["Control", "Optogenetic"], df2) scatter(:Xaxis,:Mean, group = :Treatment, color = :color, markersize = 7)
@df filter(r -> r.Treatment in ["Control",  "SB242084"], df2) scatter(:Xaxis,:Mean, group = :Treatment, color = :color, markersize = 7)
@df filter(r -> r.Treatment in ["Control", "Altanserin"], df2) scatter(:Xaxis,:Mean, group = :Treatment, color = :color, markersize = 7)

df2 = combine(groupby(df1,[:Phase,:Treatment])) do dd
    summarize(dd,:PokeFromLastRew, :ODC)
end
Drug_colors!(df2)
@df filter(r -> r.Phase == "Citalopram", df2) scatter(:Xaxis,:Mean, group = :Treatment, color = :color, markersize = 7)
@df filter(r -> r.Phase == "Optogenetic", df2) plot(:Xaxis,:Mean, group = :Treatment, linecolor = :color, markersize = 7)
@df filter(r -> r.Phase ==  "SB242084", df2) scatter(:Xaxis,:Mean, group = :Treatment, color = :color, markersize = 7)
@df filter(r -> r.Phase == "Altanserin", df2) plot(:Xaxis,:Mean, group = :Treatment, linecolor = :color, markersize = 7)
##Plot deltas
transform!(groupby(df1,[:MouseID,:Phase]), :ODC => mean)
df1[!,:ODC_norm] = df1.ODC ./ df1.ODC_mean
df2 = combine(groupby(df1,[:Treatment,:MouseID,:PokeFromLastRew])) do dd
    (ODC_norm = mean(dd.ODC_norm),)
end
open_html_table(df2)
df3 = unstack(df2,:Treatment,:ODC_norm)
for c in ["Citalopram","Optogenetic","Altanserin","SB242084"]
    df3[!,Symbol("Delta" * c)] = df3[:,Symbol(c)] - df3[:,:Control]
end
l = 18
plot_deltafromrew(df3,"Optogenetic"; limit = l)
plot_deltafromrew(df3,"Altanserin"; limit = l)
plot_deltafromrew(df3,"Citalopram"; limit = 11)
plot_deltafromrew(df3,"SB242084"; limit = 10)
# replot simple 2 lines
df4 = combine(groupby(df3,:MouseID), :DeltaOptogenetic => skipmean)
opto = filter(r -> !isnan(r.DeltaOptogenetic_skipmean),df4)
mean(opto.DeltaOptogenetic_skipmean)
## All controls joined
combined_controls = combine(groupby(df1,[:Treatment])) do dd
    summarize(dd,:PokeFromLastRew,:ODC_norm)
end
Drug_colors!(combined_controls)
l = 100
ongoing = filter(r -> r.Treatment in ["Control", "Altanserin"] && r.Xaxis < l, combined_controls)
@df  ongoing plot(:Xaxis,:Mean,
    ribbon = :SEM, group = :Treatment, color =:color)

ongoing = filter(r -> r.Treatment in ["Control", "Optogenetic"] && r.Xaxis < l, combined_controls)
@df ongoing plot(:Xaxis,:Mean,
    ribbon = :SEM, group = :Treatment, color =:color)

##
separate_controls = combine(groupby(df1,[:Phase,:Treatment])) do dd
    summarize(dd,:PokeFromLastRew,:ODC_norm)
end
Drug_colors!(separate_controls)
l = 12
ongoing = filter(r -> r.Phase == "Altanserin" && r.Xaxis < l, separate_controls)
@df ongoing plot(:Xaxis,:Mean, ribbon = :SEM, color = :color, group = :Treatment)
ongoing = filter(r -> r.Phase == "SB242084" && r.Xaxis < l, separate_controls)
@df ongoing plot(:Xaxis,:Mean, ribbon = :SEM, color = :color, group = :Treatment)
##
open_html_table(df3)
gd = groupby(df3,[:PokeFromLastRew])

df4 = combine(gd,:DeltaCitalopram => skipmean => :DeltaCitalopram,
    :DeltaOptogenetic => skipmean => :DeltaOptogenetic,
    :DeltaAltanserin=> skipmean => :DeltaAltanserin,
    :DeltaSB242084 => skipmean => :DeltaSB242084)
open_html_table(df4)

phase = "Optogenetic"
c_name = "Delta" * phase
c_symbol = Symbol(c_name)
c_symbol
df3.PokeFromLastRew
df3.DeltaOptogenetic
@df filter(r -> r.PokeFromLastRew < 15, df3) scatter(:PokeFromLastRew, cols(c_symbol), markercolor = :grey)
@df filter(r -> r.PokeFromLastRew < 15, df4) scatter!(:PokeFromLastRew, c_symbol, markersize = 8, markercolor = get(drug_colors,phase,:red))
Plots.abline!(0,0, legend = false)


@df filter(r -> r.PokeFromLastRew < 15, df3) scatter(:PokeFromLastRew, :DeltaAltanserin)
Plots.abline!(0,0)
##
c_baseline = f_full.β[1]
b_odc = f_full.β[2]
b_odcrew = f_full.β[8] ##ODC&PokeFromLast
b_sb = f_full.β[20]
b_alt = f_full.β[19]
b_opt = f_full.β[18]
b_cit = f_full.β[17]
r = range(minimum(df1.ODC),maximum(df1.ODC), length = 10)
plot(r, r .* b_odc)
## Plot logistic sinusoid
params = f_full.β
intercept = params[1]
O_D_C = params[2]
PFLR = params[3]
Citalopram = params[4]
Optogenetic = params[5]
Altanserin = params[6]
SB242084 = params[7]
ODC_PFLR = params[8]
ODC_Citalopram = params[9]
ODC_Optogenetic = params[10]
ODC_Altanserin = params[11]
ODC_SB242084 = params[12]
PFLR_Citalopram = params[13]
PFLR_Optogenetic = params[14]
PFLR_Altanserin = params[15]
PFLR_SB242084 = params[16]
ODC_PFLR_Citalopram = params[17]
ODC_PFLR_Optogenetic = params[18]
ODC_PFLR_Altanserin = params[19]
ODC_PFLR_SB242084 = params[20]

# by plugging in the mean as the value for odc,
# I'll be generating plots that show the relationship between PokesAfterLast and
# the outcome "for someone with an average ODC".
odc_val = minimum(df1.ODC)
afterlast_range = 1:10
# the reference group
a_logits = [intercept +
    O_D_C * odc_val +
    PFLR * af +
    Citalopram * 0 +
    Optogenetic * 0 +
    Altanserin * 0 +
    SB242084 * 0 +
    ODC_PFLR * odc_val * af +
    ODC_Citalopram * odc_val * 0 +
    ODC_Optogenetic * odc_val * 0 +
    ODC_Altanserin * odc_val * 0 +
    ODC_SB242084 * odc_val * 0 +
    PFLR_Citalopram * af * 0 +
    PFLR_Optogenetic * af * 0 +
    PFLR_Altanserin * af * 0 +
    PFLR_SB242084 * af * 0 +
    ODC_PFLR_Citalopram * odc_val * af +
    ODC_PFLR_Optogenetic * odc_val * af +
    ODC_PFLR_Altanserin * odc_val * af +
    ODC_PFLR_SB242084 * odc_val * af for af in afterlast_range]

a_probs = [exp(a) / (1 + exp(a)) for a in a_logits]
plot(1 .- a_probs)
bare = intercept + O_D_C * odc_val
exp(bare)/(1 + exp(bare))

d = countmap(df1[df1[:,:Leave],:PokeFromLastRew])
p = plot()
for (k,v) in d
    scatter!(k,v)
end
p
