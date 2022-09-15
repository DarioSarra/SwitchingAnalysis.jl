"""
    test_leave(df, treatment)
    Calculates the mean average reward rate and reward rate at leaving per mouse
    Performs a Ttest on the 2 vectors (avg vs leaving mean values)
"""
function test_leave(df, treatment)
    df0 = filter(r-> r.Treatment == treatment && !r.LeaveWithReward && r.Trial <= 40 , df)
    nrow(df0) == 0 && error("filtered out everything")
    df1 = combine(groupby(df0,:MouseID),
        [:AverageRewRate, :LeavingRewRate] .=> mean .=> [:AverageRewRate, :LeavingRewRate])
    sort!(df1, :MouseID)
    OneSampleTTest(df1.AverageRewRate, df1.LeavingRewRate)
    # wilcoxon(df0,:AverageRewRate, :LeavingRewRate; f = x -> mean(skipmissing(x)))
end


"""
    Ttest_drugs(df, var, drug)

    Uses the phase column to filter the data belonging only to `drug` phase
    Calculates the mean of `var` per mouse and treatment (drug vs control)
    Performs a Ttest on the 2 vectors (drug vs control mean values)
"""
function Ttest_drugs(df, var, drug)
    df0 = filter(r -> r.Phase == drug, df)
    df1 = transform(df0, var => :Y)
    gd1 = groupby(df1,[:MouseID,:Treatment])
    df2 = combine(gd1, :Y => mean => :Y)
    df3 = unstack(df2,:Treatment,:Y)
    dropmissing!(df3)
    OneSampleTTest(df3[:,Symbol(drug)], df3[:,:Control])
end

"""
    Ttest_drugs(df, var)

    Automatically identifies all the drug in the `df` to run a Ttest on `var`
    for each of them using Ttest_drugs(df, var, drug). Results are collected in
    a dictionary that uses drug names as keys
"""
function Ttest_drugs(df, var)
    cases = filter(t-> t != "Control",string.(union(df[:,:Treatment])))
    res = Dict([(Symbol(d), (Ttest_drugs(df,var,d))) for d in cases])
end

"""
    collect_Ttest(t::OneSampleTTest; group = "None")

    Reorganises the output of HypothesisTests.OneSampleTTest in a dataframe.
    if t is a dictionary loops through each key to collect the data
"""
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
