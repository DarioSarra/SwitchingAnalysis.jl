mutable struct KDensity{R<:AbstractRange}
    "Gridpoints for evaluating the density."
    x::R
    "Kernel density at corresponding gridpoints `x`."
    density::Vector{Float64}
end

function KDensity(v)
    k = KernelDensity.kde(v)
    #probability = k.density./sum(k.density)
    probability = k.density .* step(k.x)
    KDensity(k.x, probability)
end

function trim_dist(k::KDensity, percent = 99)
    val = (100 - percent) / 200
    low_idx = findfirst(x-> x> val,cumsum(k.density))
    high_idx = findfirst(x-> x> 1-val,cumsum(k.density))
    (low = k.x[low_idx], high = k.x[high_idx])
end
