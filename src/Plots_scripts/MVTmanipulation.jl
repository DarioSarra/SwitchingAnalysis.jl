include("filtering.jl");
gr(size=(600,600), tick_orientation = :out, grid = false,
    linecolor = :black,
    markerstrokecolor = :black,
    thickness_scaling = 2,
    markersize = 6)
check = combine(groupby(pokes,[:Phase,:Day]),:Treatment => t -> [union(t)],:Stim => t -> [union(t)])
    open_html_table(sort!(check,:Day))
    check = combine(groupby(streaks,[:Phase,:Day]),:Treatment => t -> [union(t)],:Stim => t -> [union(t)])
    open_html_table(sort!(check,:Day))
################################ Adjust Streaks table ##################################

################################ Adjust Pokes table ##################################
filt_1 = filter(r->r.Treatment == "Control",pokes)
union(pokes.Treatment)
gd1 = groupby(filt_1,[:MouseID,:TimeFromLeaving,:Protocol])
df2 = combine(gd1, :CumRewTrial => mean => :CumRewTrial)
gd2 = groupby(df2,[:Protocol,:TimeFromLeaving])
df3 = combine(gd2, :CumRewTrial => mean, :CumRewTrial => sem)
Protocol_colors!(df3)

@df df3 scatter(:TimeFromLeaving,:CumRewTrial_mean, group = :Protocol, xlims = (0,30), markersize = 4, color = :color)
##
gd1 = groupby(streaks,[:Protocol,:MouseID,:Phase,:Treatment])
df1 = combine(gd1,
    :Leaving_NextPrew => mean => :Leaving_NextPrew,
    :AverageRewRate => mean => :AverageRewRate)

gd2 = groupby(df1,:Treatment)
df2 = combine(gd2,
    :AverageRewRate .=> [mean, median], :AverageRewRate .=> [sem,CIq],
    :Leaving_NextPrew .=> [mean, median], :Leaving_NextPrew .=> [sem, CIq])

filt_2 = filter(r->r.Treatment in ["Altanserin", "SB242084", "Control", "Citalopram", "Optogenetic"],df2)
res = combine(groupby(filt_2, :Treatment)) do dd
    DataFrame(Condition = ["Average", "At Leaving"],
        Mean = [dd[1,:AverageRewRate_mean], dd[1,:Leaving_NextPrew_mean]],
        Sem = [dd[1,:AverageRewRate_sem], dd[1,:Leaving_NextPrew_sem]],
        Median = [dd[1,:AverageRewRate_median], dd[1,:Leaving_NextPrew_median]],
        CIq = [dd[1,:AverageRewRate_CIq], dd[1,:Leaving_NextPrew_CIq]])
    end
Drug_colors!(res)
@df res scatter(:Condition,:Mean, yerror = :Sem, color = :color, xlims = (0.25,1.75), markeralpha=0.7, group = :Treatment, legend = false)
@df res scatter(:Condition,:Median, yerror = :Sem, color = :color, xlims = (0.25,1.75), markeralpha=0.7, group = :Treatment, legend = false)
##
#=
1- bin cumulative rewards over time from trial start
1b- skip interpoke interval cost
    1- accumulate poke duration over trial
2- fit the cumulative with polyfit LsqFit
3- find average travel speed
4- find a tangent
=#

filt_3  = filter(r->r.Treatment in ["Altanserin", "SB242084", "Control", "Citalopram", "Optogenetic"],pokes)
gd = groupby(filt_3, [:Day,:MouseID, :Trial])
transform!(gd,[:PokeIn,:PokeOut] => ((i,o) -> (round.(o .- i[1], digits = 1))) => :BinnedTrialTime,
    [:PokeIn,:PokeOut] => ((i,o) -> round.(cumsum(o .- i), digits = 1)) => :ForagingTime,
    :Reward => cumsum => :CumTrialReward)

timedf = combine(groupby(filt_3, [:Day,:MouseID, :Trial, :Treatment])) do dd
    timerange = 0:0.1:maximum(dd.BinnedTrialTime)
    # timerange = 0:0.1:maximum(dd.ForagingTime)
    df = DataFrame(Time = collect(timerange), Rew = 0)
    for r in eachrow(dd)
        df[findfirst(timerange .== r.BinnedTrialTime),:Rew] = r.Reward
        # df[findfirst(timerange2 .== r.ForagingTime),:Rew] = r.Reward
    end
    df.CumRew = cumsum(df.Rew)
    return df
end
timedf2 = combine(groupby(filt_3, [:Day,:MouseID, :Trial, :Treatment])) do dd
    # timerange = 0:0.1:maximum(dd.BinnedTrialTime)
    timerange = 0:0.1:maximum(dd.ForagingTime)
    df = DataFrame(Time = collect(timerange), Rew = 0)
    for r in eachrow(dd)
        # df[findfirst(timerange .== r.BinnedTrialTime),:Rew] = r.Reward
        df[findfirst(timerange .== r.ForagingTime),:Rew] = r.Reward
    end
    df.CumRew = cumsum(df.Rew)
    return df
end
# open_html_table(timedf[2400:3300,:])
union(timedf.Treatment)
## Fit cumulative per session
using LsqFit
function fit_cumulative(cum,time)
    model(x,p) = @. (1 - exp(-p[1]*x)) *p[2]
    p0 = [0.5,1]
    fitting = curve_fit(model, cum, time, p0)
    # return DataFrame(Coef = fitting.param[1], Scale = fitting.param[2])
    # return (fitting.param...,)
    return fitting.param
end
using Roots
function MVTtangent(coef, P)
    # P is the point where the line pass through
    # cumulative to be tangential to
    c(x) = @. (1 - exp(-coef[1]*x))*coef[2]
    #derivative of the cum, equal to the slope
    d(x) = @. coef[1] * exp(-coef[1]*x) *coef[2]
    #solve using slope-intercept form of the line
    # y-y0 = m(x-x0)
    # x0 has to be a point on the curve so express it in this way
    # y-c(x0) = d(x0)(x-x0)
    # solve passing for the point P
    # yp -c(x0) = d(x0)(xp-x0)
    # yp -c(x0) - d(x0)(xp-x0) = 0
    # f(x) = P[2] - (1 - exp(-coef[1]*x))*coef[2] - (coef[1] * exp(-coef[1]*x))*coef[2]*(P[1]-x)
    f(x) = P[2] - c(x) - d(x)*(P[1]-x)
    x0 = Roots.find_zero(f,0) # search x0 in a reasonable range of trial time
    #find inercept using P and m = d(x0)
    # y = mx +q
    # P[2] = d(x0)*P[1] + q
    # q = -d(x0)*P[1] - P[2]
    q = -d(x0)*P[1] - P[2]
    # sol(x) = @. x * d(x0) + q
    # return DataFrame(OptLeave = x0, Slope = d(x0), Intercept = q)
    return (x0,d(x0),q)
end

control = filter(r->r.Treatment == "Control", timedf)
coef = fit_cumulative(control.Time, control.CumRew)
control2 = filter(r->r.Treatment == "Control", timedf2)
coef2 = fit_cumulative(control2.Time, control2.CumRew)
GainModel(x,p) = @. (1 - exp(-p[1]*x)) *p[2]
xaxis = 0:0.5:35
plot(xaxis,GainModel(xaxis,coef), label = "TrialTime", legend = :bottomright)
plot!(xaxis,GainModel(xaxis,coef2), label = "ForagingTime", linecolor = :purple)
## Different gain models per animal
coef3 = combine(groupby(control,[:MouseID]), [:CumRew,:Time] => ((cr,t) -> [fit_cumulative(cr,t)])=> :Coeff)
coef3[!,:GlobCoeff] .= [coef]
open_html_table(coef3)
##
# timedf2 = combine(groupby(timedf,[:MouseID,:Day, :Treatment]),
#     # [:Time,:CumRew] => ((t,r)-> fit_cumulative(t,r)) => [:Coef,:Scale])
#     [:Time,:CumRew] => ((t,r)-> fit_cumulative(t,r)) => :Params)
## Costs
# travel
pretravel = filter(r->r.Treatment in ["Altanserin", "SB242084", "Control", "Citalopram", "Optogenetic"],streaks)
trav1 = combine(groupby(pretravel,[:MouseID,:Treatment]),
    # :ROI_Leaving_Time => median => :Travel,
    :Poking_Travel_to => median => :Travel,
    :Poking_duration => median => :Leaving)
# Poking
pretravel.ROI_Leaving_Time

function pokecost(rvec,pokevec)
    v = pokevec[.!rvec]
    median(skipmissing(v))
end
filt_3.Pre_Interpoke
pcost = combine(groupby(filt_3, [:MouseID, :Treatment]), [:Reward,:PokeDuration] => ((r,p) -> pokecost(r,p)) => :PokeCost,
    :Pre_Interpoke => (i -> median(skipmissing(i))) => :InterpokeCost)
cost = leftjoin(trav1,pcost, on=[:MouseID, :Treatment])
params = leftjoin(cost, coef3; on=:MouseID)
## Optimal leaving
timedf3 = combine(groupby(params,[:MouseID,:Treatment]),
    [:Travel, :PokeCost, :Coeff] => ByRow(((trav,pcost, coeff) -> MVTtangent(coeff, [-trav+pcost,0.0]))) => [:OptLeave, :Slope, :Intercept],
    :PokeCost,:Travel,:Leaving)
timedf3.Diff = timedf3.Leaving .- timedf3.OptLeave
sort!(timedf3,[:Treatment,:MouseID])
open_html_table(timedf3)
timedf4 = combine(groupby(timedf3,:Treatment)) do dd
    x = Vector(dd.Diff)
    wilcoxon(x)
end
open_html_table(timedf4)
Drug_colors!(timedf4)
@df timedf4 scatter(string.(:Treatment), :Median, color = :color, legend = false)
Plots.abline!(0,0,color = :black, linestyle = :dash)
##GLM
fm = @formula(Diff ~ 1 + Treatment + (1|MouseID+Treatment))
fm1 = fit(MixedModel, fm, timedf3)
## Leaving by Poke_within_Trial
#= using median interpoke and median unrewarded pokes duration we can normalize median travel time on the same
abstract unit measure =#
#1 filter pokes and streaks
fpokes = filter(r->r.Treatment in ["Altanserin", "SB242084", "Control", "Citalopram", "Optogenetic"],pokes)
fstreaks = filter(r->r.Treatment in ["Altanserin", "SB242084", "Control", "Citalopram", "Optogenetic"],streaks)
#2 trial cumulative reward in pokes df
gd = groupby(fpokes, [:Day,:MouseID, :Trial])
transform!(gd,:Reward => cumsum => :CumTrialReward)
#3 calculate median travel, per session
travcost = combine(groupby(fstreaks,[:MouseID,:Treatment,:Day]),
    # :Poking_Travel_to => (t->median(t[t.>=1])) => :Travel)
    :Poking_Travel_to => median => :Travel,
    :Num_pokes => mean => :Leave
    )
#4 calculate median poke duration and median interpoke duration
pcost = combine(groupby(fpokes,[:MouseID,:Treatment,:Day]),
    [:Reward,:PokeDuration] => ((r,p) -> pokecost(r,p)) => :PokeCost,
    :Pre_Interpoke => (i -> median(skipmissing(i))) => :InterpokeCost)
#5 join costs datasets
costs = leftjoin(travcost,pcost, on = [:MouseID,:Treatment,:Day])
costs[!,:Pcost] = costs.InterpokeCost .+ costs.PokeCost
costs[!,:NormTravel] = -costs.Travel ./ costs.Pcost
#6 calculate cumulative reward per ...
GainModel(x,p) = @. (1 - exp(-p[1]*x)) *p[2]
# coef = combine(groupby(fpokes,[:Treatment,:Day]),
#     [:CumTrialReward,:Poke_within_Trial] => ((cr,t) -> [fit_cumulative(cr,t)])=> :Coeff)
coef = combine(groupby(filter(r-> r.Treatment == "Control", fpokes),[:MouseID]),
    [:CumTrialReward,:Poke_within_Trial] => ((cr,t) -> [fit_cumulative(cr,t)])=> :Coeff)
res = leftjoin(costs, coef, on = [:MouseID])
#7 find optimal leaving time per session
groups = groupby(res, [:MouseID,:Treatment,:Day])
transform!(groups,
    [:NormTravel, :Coeff] => ByRow(((ntrav, coeff) -> MVTtangent(coeff, [ntrav,0.0]))) => [:OptLeave, :Slope, :Intercept]
    )

open_html_table(sort!(res,:Treatment))
#8 calculate difference between otpimal and actual leaving time
res[!,:Diff] = res.Leave .- res.OptLeave
fm = @formula(Diff ~ 1 + Treatment + (1|MouseID+Treatment))
fm1 = fit(MixedModel, fm, res)
##
prov = filter(r-> r.Treatment == "Control", fstreaks)
prov.Trial_Travel_to
prov2 = combine(groupby(prov,:MouseID), :Poking_Travel_to => mean, :Trial_Travel_to => mean)
combine(prov2,:Trial_Travel_to_mean .=> [mean,std, sem] .=> [:Mean,:Std,:Sem])
combine(prov,:Trial_Travel_to .=> [mean,std, sem])
##
reswilc = combine(groupby(res,:Treatment)) do dd
    x = Vector(dd.Diff)
    wilcoxon(x)
end
Drug_colors!(reswilc)
@df reswilc scatter(string.(:Treatment), :Median, yerror = :CI, color = :color, legend = false)
Plots.abline!(0,0,color = :black, linestyle = :dash)
##

##
function randpg()
    points = []
    for i in 1:6
        v = rand(1:6,4)
        deleteat!(v,findmin(v)[2])
        push!(points, sum(v))
    end
    return points
end
