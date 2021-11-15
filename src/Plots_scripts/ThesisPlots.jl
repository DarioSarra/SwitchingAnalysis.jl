include("filtering.jl");
using Plots.PlotMeasures
gr(size=(600,600), tick_orientation = :out, grid = false,
    linecolor = :black,
    markerstrokecolor = :black,
    thickness_scaling = 2,
    markersize = 6) #,
    # left_margin = -10mm,
    # bottom_margin = -10mm)
## Example session
orig = CSV.read(joinpath(files_loc,"pokes.csv"), DataFrame)
t_lim = 50
example = filter(r -> r.MouseID == "c2" && r.Day == Date(2016,03,11) && r.Trial <= t_lim, orig)
example.outcome = [x ? (y == "R" ? :green : :orange) : :lightgrey for (x,y) in zip(example.Reward,example.Side)]
example.Side
m = 10
@df example scatter(:Trial,:Poke_within_Trial, markershape = :square, markersize = 4, label = false, mswidth = 1, xticks = 0:10:180,
    size = (t_lim*m,20*m), markercolor = :outcome, ylims = (0,20), thickness_scaling = 1)
savefig(joinpath(figs_loc,"Thesis","Fig1","C-ExampleSession.png"))
## Distributions
Pstate= Prew(1:20)
Pstate[!,:Color] = [get(protocol_colors,x,:grey) for x in Pstate.Protocol];
@df Pstate plot(:Poke,:Prew, group = :Protocol, linecolor = :Color, legend = false)
    @df Pstate scatter!(:Poke,:Prew, group = :Protocol, color = :Color, mswidth = 0)
    xlabel!("Poke number")
    ylabel!("Reward probability")
savefig(joinpath(figs_loc,"Thesis","Fig1","D-Distributions.pdf"))
##
check = combine(groupby(orig,[:Phase,:Day]),:Treatment => t -> [union(t)],:Stim => t -> [union(t)])
open_html_table(sort!(check,:Day))
check = combine(groupby(streaks,[:Phase,:Day]),:Treatment => t -> [union(t)],:Stim => t -> [union(t)])
open_html_table(sort!(check,:Day))
orig = CSV.read(joinpath(files_loc,"streaks.csv"), DataFrame)
check0 = filter(r->r.Day == Date(2016,07,18),orig)
check1 = combine(groupby(check0,[:MouseID]),:Treatment => t -> [union(t)],:Stim => t -> [union(t)])
open_html_table(check1)
check3 = combine(groupby(check0,[:Stim,:MouseID]), :Num_pokes => mean => :Num_pokes)
check4 = combine(groupby(check3,[:Stim]), :Num_pokes .=> [mean, sem] .=> [:Mean, :SEM])
@df check4 bar(:Mean, yerror = :SEM)
check5= combine(groupby(orig,[:MouseID, :Treatment]), :Trial => maximum)
open_html_table(sort(check5, :MouseID))
##
function plot_perprotocol(df,var, treatment)
    df0 = filter(r-> r.Treatment == treatment, df)
    nrow(df0) == 0 && error("filtered out everything")
    df1 = combine(groupby(df0,[:Protocol,:MouseID]), var => mean => var)
    df2 = combine(groupby(df1,[:Protocol]), var .=> [mean, sem] .=> [:Mean, :SEM])
    sort!(df2, :Protocol)
    Protocol_colors!(df2)
    @df df2 scatter(:Mean, yerror = :SEM, color = :color, legend = false,
    xticks = ([1,2,3],["Hard", "Medium","Easy"]), xlims = (0.5,3.5))
end

function test_perprotocol(df,var, treatment)
    df0 = filter(r-> r.Treatment == treatment , df)
    nrow(df0) == 0 && error("filtered out everything")
    df0.Y = df0[:,var]
    f0 = @formula (Y ~ 1 + (1|MouseID))
    m0 = fit(MixedModel, f0, df0)
    f1 = @formula (Y ~ 1 + Protocol + (1|MouseID))
    m1 = fit(MixedModel, f1, df0)
    MixedModels.likelihoodratiotest(m0, m1), m1
end

function plot_leave(df,treatment)
    df0 = filter(r-> r.Treatment == treatment && !r.LeaveWithReward && r.Trial <= 40 , df)
    nrow(df0) == 0 && error("filtered out everything")
    df1 = combine(groupby(df0,:MouseID),
        [:AverageRewRate, :LeavingRewRate] .=> mean .=> [:AverageRewRate, :LeavingRewRate])
    df2 = combine(df1,
        :AverageRewRate .=> [mean, sem] .=> [:AV_Mean, :AV_SEM],
        :LeavingRewRate .=> [mean, sem] .=> [:L_Mean, :L_SEM])
    df3 = DataFrame(Condition = ["Average", "At Leaving"],
        Mean = [df2[1,:AV_Mean], df2[1,:L_Mean]],
        SEM = [df2[1,:AV_SEM], df2[1,:L_SEM]])
    plt = @df df3 scatter(:Mean, yerror = :SEM, color = :grey, legend = false,
    xticks = ([1,2],["Average", "At Leaving"]))
    show(plt)
    return df3
end
function test_leave(df, treatment)
    df0 = filter(r-> r.Treatment == treatment && !r.LeaveWithReward && r.Trial <= 40 , df)
    nrow(df0) == 0 && error("filtered out everything")
    df1 = combine(groupby(df0,:MouseID),
        [:AverageRewRate, :LeavingRewRate] .=> mean .=> [:AverageRewRate, :LeavingRewRate])
    sort!(df1, :MouseID)
    OneSampleTTest(df1.AverageRewRate, df1.LeavingRewRate)
    # wilcoxon(df0,:AverageRewRate, :LeavingRewRate; f = x -> mean(skipmissing(x)))
end
## Prew at leaving vs Average
## CHECK THIS FOR THE DRUGS
df = plot_leave(streaks,"Control")
    xaxis!(xlims = (0.5,2.5), xlabel = "Place holder")
    yaxis!(yticks = (0:0.02:0.4), ylabel = "Reward rate", ylims = (0.19,0.24))
    plot!([1,2],[0.235,0.235])
    annotate!(1.5,0.238,Plots.text("n.s.",16))
df
savefig(joinpath(figs_loc,"Thesis","Fig2","A-RewRate.pdf"))
test_leave(streaks,"Control")
## Prew at leaving per protocol
plot_perprotocol(streaks, :Leaving_NextPrew, "Control")
    xlabel!("Trial type")
    yaxis!(yticks = (0:0.05:0.4),  ylabel = "Reward probability", ylims = (0.23,0.31))
    plot!([1,3],[0.3025,0.3025])
    annotate!(2,0.31,Plots.text("n.s.",16))
savefig(joinpath(figs_loc,"Thesis","Fig2","B-Prew_Protocol.pdf"))
test_perprotocol(streaks, :Leaving_NextPrew, "Control")
## Rewards per protocol
plot_perprotocol(streaks, :Num_Rewards, "Control")
    xlabel!("Trial type")
    yaxis!(ylabel = "Rewards per trial", yticks = 0:1:5,ylims = (1,5.5))
    plot!([1,3],[5.3,5.3])
    annotate!(2,5.4,Plots.text("*",16))
savefig(joinpath(figs_loc,"Thesis","Fig2","C-Rewards.pdf"))
test_perprotocol(streaks, :Num_Rewards, "Control")
## Pokes per protocol
plot_perprotocol(streaks, :Num_pokes, "Control")
    xlabel!("Trial type")
    yaxis!(yticks = (0:1:15), ylabel = "Pokes per trial", ylims = (11.1,15.2))
    plot!([1,3],[14.9,14.9])
    annotate!(2,15,Plots.text("*",16))
savefig(joinpath(figs_loc,"Thesis","Fig2","D-Pokes.pdf"))
test_perprotocol(streaks, :Num_pokes, "Control")
## Slope After Last
tr_streaks = filter(r->r.Treatment =="Control" &&
    !r.LeaveWithReward &&
    r.Last_Reward > 0 ,
    streaks)
    df1 = combine(groupby(tr_streaks,[:MouseID, :Last_Reward]), :AfterLast => mean => :AfterLast)
    df2 = combine(groupby(tr_streaks,:Last_Reward), :AfterLast .=> [mean, sem])
    sort!(df2,:Last_Reward)
    dropnan!(df2)
@df df2 plot(:Last_Reward, :AfterLast_mean, ribbon = :AfterLast_sem, xlims = (1,15),
    linecolor = :grey, fillcolor = :grey, label = false)
    xlabel!("Last rewarded poke")
    yaxis!(ylabel = "Pokes after last reward", ylims = (4.8,8), yticks = 0:1:10)
df0 = filter(r-> r.Treatment == "Control" , streaks)
nrow(df0) == 0 && error("filtered out everything")
f0 = @formula (AfterLast ~ 1 + (1|MouseID))
m0 = fit(MixedModel, f0, df0)
f1 = @formula (AfterLast ~ 1 + Last_Reward + (1|MouseID))
m1 = fit(MixedModel, f1, df0)
MixedModels.likelihoodratiotest(m0, m1)
savefig(joinpath(figs_loc,"Thesis","Fig2","E-Slope.pdf"))
## AfterLast
plot_perprotocol(streaks, :AfterLast, "Control")
    xlabel!("Trial type")
    yaxis!(yticks = (0:1:8), ylabel = "Pokes after last reward", ylims = (5,7))
    plot!([1,3],[6.8,6.8])
    annotate!(2,6.85,Plots.text("*",16))
savefig(joinpath(figs_loc,"Thesis","Fig2","F-AfterLast.pdf"))
test_perprotocol(streaks, :AfterLast, "Control")

#################################################################
#################################################################
#################################################################
##
function test_drugs(df,var)
    df1 = transform(df, var => :Y)
    m1 = fit!(LinearMixedModel(@formula(Y ~ 1 + Protocol + (1|MouseID)),df1))
    m2 = fit!(LinearMixedModel(@formula(Y ~ 1 + Treatment + Protocol + (1|MouseID)),df1))
    m3 = fit!(LinearMixedModel(@formula(Y ~ 1 + Treatment * Protocol + (1|MouseID)),df1))
    l1 = MixedModels.likelihoodratiotest(m1,m2)
    l2 = MixedModels.likelihoodratiotest(m2,m3)
    return m1, m2, m3, l1, l2
end

function plot_drugs(df,var)
    df1 = transform(df, var => :Y)
    gd1 = groupby(df1,[:Protocol,:MouseID,:Phase,:Treatment])
    df2 = combine(gd1, :Y => mean => :Y)
    gd2 = groupby(df2,[:Protocol,:Treatment])
    df3 = combine(gd2, :Y .=> [mean, sem])
    Drug_colors!(df3)
    @df df3 scatter(:Protocol, :Y_mean, yerror = :Y_sem,
        group = :Treatment, color = :color,label = false,
        xticks = ([0.5,0.75,1],["Hard", "Medium","Easy"]), xlims = (0.4,1.1),
        xlabel = "Trial type")
end

function Ttest_drugs(df, var, drug)
    df0 = filter(r -> r.Phase == drug, df)
    df1 = transform(df0, var => :Y)
    gd1 = groupby(df1,[:MouseID,:Treatment])
    df2 = combine(gd1, :Y => mean => :Y)
    df3 = unstack(df2,:Treatment,:Y)
    dropmissing!(df3)
    OneSampleTTest(df3[:,Symbol(drug)], df3[:,:Control])
end

function Ttest_drugs(df, var)
    cases = filter(t-> t != "Control",string.(union(df[:,:Treatment])))
    res = Dict([(Symbol(d), (Ttest_drugs(df,var,d))) for d in cases])
end

function collect_Ttest(t::OneSampleTTest; group = "None")
    DataFrame(Treatment = group, Mean = t.xbar, CI = t.xbar - confint(t)[1], p = pvalue(t))
end

function collect_Ttest(t::Dict{Symbol,OneSampleTTest})
    res = DataFrame(Treatment = [], Mean = [], CI = [], p = [])
    for k in keys(t)
        append!(res, collect_Ttest(t[k], group = string(k)))
    end
    res
end

function plot_Ttest(df, var)
    tt = Ttest_drugs(df, var)
    res = collect_Ttest(tt)
    Drug_colors!(res)
    @df res scatter(:Treatment, :Mean, yerror = :CI,
        color = :color, legend = false,
        xlabel = "Treatment", xlims = (0,2))
        Plots.abline!(0,0,color = :black, linestyle = :dash)
end
## Figure 3 Selective
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
savefig(joinpath(figs_loc,"Thesis","Fig3","A-Sel_RewProb.pdf"))
## Num pokes
plot_drugs(test_sel, :Num_pokes)
    ylabel!("Pokes per trial")
pokes_sel_m1,pokes_sel_m2, pokes_sel_m3, pokes_sel_l1, pokes_sel_l2 =
    test_drugs(test_sel,:Num_pokes)
savefig(joinpath(figs_loc,"Thesis","Fig3","B-Sel_Pokes.pdf"))
## AfterLast
plot_drugs(test_sel, :AfterLast)
    ylabel!("Pokes after last reward")
after_sel_m1,after_sel_m2, after_sel_m3, after_sel_l1, after_sel_l2 =
    test_drugs(test_sel,:AfterLast)
savefig(joinpath(figs_loc,"Thesis","Fig3","C-Sel_AfterLast.pdf"))
## T test Reward number
tt = Ttest_drugs(test_sel, :Num_Rewards)
plot_Ttest(test_sel, :Num_Rewards)
    ylabel!("Delta number of reward")
    ylims!(-0.6,0.32)
    annotate!([(0.5,0.3,Plots.text("n.s.",16)), (1.5,0.28,Plots.text("*",16))])
savefig(joinpath(figs_loc,"Thesis","Fig3","D-Sel_RewNum.pdf"))
##
tt = Ttest_drugs(test_sel, :Num_pokes)
tt = Ttest_drugs(test_sel, :AfterLast)
plot_Ttest(test_sel, :Num_pokes)
    ylabel!("Delta pokes after last reward")
    # ylims!(-0.6,0.32)
    annotate!([(0.5,0.3,Plots.text("n.s.",16)), (1.5,0.28,Plots.text("*",16))])

#################################################################
#################################################################
#################################################################
## Figure 4 Global
test_glo = filter(r->r.Phase in ["Optogenetic","Citalopram", "Control"] &&
    r.Treatment in ["Optogenetic","Citalopram", "Control"],streaks)
Drug_colors!(test_glo)

## Prew at leaving
plot_drugs(test_glo, :Leaving_NextPrew)
    ylabel!("Reward probability")
prew_sel_m1,prew_sel_m2, prew_sel_m3, prew_sel_l1, prew_sel_l2 =
    test_drugs(test_glo,:Leaving_NextPrew)
savefig(joinpath(figs_loc,"Thesis","Fig4","A-Sel_RewProb.pdf"))
## Num pokes
plot_drugs(test_glo, :Num_pokes)
    ylabel!("Pokes per trial")
pokes_sel_m1,pokes_sel_m2, pokes_sel_m3, pokes_sel_l1, pokes_sel_l2 =
    test_drugs(test_glo,:Num_pokes)
savefig(joinpath(figs_loc,"Thesis","Fig4","B-Sel_Pokes.pdf"))
## AfterLast
plot_drugs(test_glo, :AfterLast)
    ylabel!("Pokes after last reward")
after_sel_m1,after_sel_m2, after_sel_m3, after_sel_l1, after_sel_l2 =
    test_drugs(test_glo,:AfterLast)
savefig(joinpath(figs_loc,"Thesis","Fig4","C-Sel_AfterLast.pdf"))
## T test Reward number
tt = Ttest_drugs(test_glo, :Num_Rewards)
plot_Ttest(test_glo, :Num_Rewards)
    yaxis!(ylabel = "Delta number of reward", ylims = (-0.51,0.2))
    xflip!()
    annotate!([(0.5,0.185,Plots.text("n.s.",16)), (1.5,0.165,Plots.text("*",16))])
savefig(joinpath(figs_loc,"Thesis","Fig4","D-Sel_RewNum.pdf"))
#################################
#################################
#################################
##
test_opt2c = filter(r->r.Phase in ["Optogenetic","SB242084_opt", "SB242084"] &&
    r.Treatment in ["Optogenetic","SB242084_opt", "Control", "SB242084"],streaks)
df0 = copy(test_opt2c)
df0[df0.Treatment .== "SB242084_opt",:Treatment] .= "Optogenetic"
df1 = combine(groupby(df0,[:Phase, :Treatment]),
    :Num_pokes .=> [mean,sem],
    :AfterLast .=> [mean,sem]
    )
open_html_table(df1)
m1 = fit!(LinearMixedModel(@formula(AfterLast ~ 1 + Treatment + Phase + (1|MouseID)),df1))
m2 = fit!(LinearMixedModel(@formula(AfterLast ~ 1 + Treatment * Phase + (1|MouseID)),df1))
l1 = MixedModels.likelihoodratiotest(m1,m2)
