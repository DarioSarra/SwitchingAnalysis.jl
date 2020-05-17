function wilcoxon(x::AbstractVector{<:Real})
    t = SignedRankTest(x)
    dd = DataFrame()
    dd[!,:Median] = [t.median]
    dd[!,:CI] = [(t.median - confint(t)[1], confint(t)[2] - t.median)]
    dd[!,:P] = [pvalue(t)]
    dd[!,:Vals] = [t.vals for i in 1:1]
    dd
end
# function wilcoxon(x::AbstractVector{<:Real})
#     t = SignedRankTest(x)
#     (Median = t.median,
#     CI = (t.median - confint(t)[1], confint(t)[2] - t.median),
#     P = pvalue(t),
#     Vals = t.vals)
# end

wilcoxon(x::AbstractVector{<:Real}, y::AbstractVector{<:Real}) = wilcoxon(x-y)

function wilcoxon(df::AbstractDataFrame,x::Symbol, by = :MouseID)
    df1 = combine(x => mean => :Mean,groupby(df,by))
    wilcoxon(df1[:,:Mean])
end


function wilcoxon(df::AbstractDataFrame,x::Symbol, y::Symbol, by = :MouseID)
    df1 = combine([x,y] => (a,b) -> (Mean_x = mean(a), Mean_y = mean(b)) ,groupby(df,by))
    wilcoxon(df1[:,:Mean_x], df1[:,:Mean_y])
end
