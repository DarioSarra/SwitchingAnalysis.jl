# abstract type PlotAnalysis end
#
# struct DiscreteAnalysis <: PlotAnalysis
#     f::Function
# end
#
# discrete_cdf = DiscreteAnalysis(ecdf)

function cumulative_discrete(V::AbstractVector)
    C = ecdf(V)
    (AN = C(C.sorted_values),Xaxis = C.sorted_values)
end
