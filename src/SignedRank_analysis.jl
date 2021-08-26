"""
    ' CIq(x::AbstractVector)'

Calculate median and 95% confidence interval around the median
"""

function CIq(x)
    m = median(x)
    (m - quantile(x,0.025), quantile(x,0.975) - m)
    # (quantile(x,[0.025,0.975])...,)
end

"""
    'wilcoxon(df::AbstractDataFrame,x::Symbol, y::Symbol, by = :MouseID; f = mean)'

x and y are paired vector to compare effect of condtion in y vs baseline in x
collect SignedRankTest analysis in a standardize table to plot
"""

function wilcoxon(x::AbstractVector{<:Real})
    t = SignedRankTest(x)
    dd = DataFrame()
    dd[!,:Median] = [t.median]
    dd[!,:CI] = [(t.median - confint(t)[1], confint(t)[2] - t.median)]
    dd[!,:P] = [pvalue(t)]
    dd[!,:Vals] = [t.vals for i in 1:1]
    dd
end

wilcoxon(x::AbstractVector{<:Real}, y::AbstractVector{<:Real}) = wilcoxon(y-x)

function wilcoxon(df::AbstractDataFrame,x::Symbol, by = :MouseID; f = mean)
    df1 = combine(x => f => :Mean,groupby(df,by))
    check = SwitchingAnalysis.complete_vals(df1)
    if any(x -> !x, check)
        println( "got NaN values and dropped them")
        dd = dropnan(df1)
    else
        dd = df1
    end
    wilcoxon(dd[:,:Mean])
end


function wilcoxon(df::AbstractDataFrame,x::Symbol, y::Symbol, by = :MouseID; f = mean)
    df1 = combine([x,y] => (a,b) -> (Mean_x = f(a), Mean_y = f(b)), groupby(df,by))
    check = SwitchingAnalysis.complete_vals(df1)
    if any(x -> !x, check)
        println( "got NaN values and dropped them")
        dd = dropnan(df1)
    else
        dd = df1
    end
    wilcoxon(dd[:,:Mean_x], dd[:,:Mean_y])
end
