mutable struct KDensity{R<:AbstractRange}
    "Gridpoints for evaluating the density."
    x::R
    "Kernel density at corresponding gridpoints `x`."
    density::Vector{Float64}
end

function KDensity(v)
    k = KernelDensity.kde(v)
    probability = k.density .* step(k.x)
    KDensity(k.x, probability)
end


function trim_dist(vec; p_limit = 0.01)
    v = jump_missing(vec)
    k = kde(v)
    ik = InterpKDE(k)
    P = [ismissing(val) ? 1 : pdf(ik, val).*step(k.x) for val in vec]
    [x > p_limit for x in P]
end

function trim_dist(df::AbstractDataFrame,x::Symbol; p_limit = 0.01)
    v = df[:,x]
    idxs = trim_dist(v; p_limit = p_limit)
    df[idxs,:]
end

function trim_dist!(df::AbstractDataFrame,x::Symbol; p_limit = 0.01)
    v = df[:,x]
    idxs = trim_dist(v; p_limit = p_limit)
    deleteat!(df,Not(idxs))
end
