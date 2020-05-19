include("filtering.jl");
##
list = ["PreVehicle",
    "Altanserin",
    "SB242084",
    "Way_100135",
    "Methysergide",
    "Citalopram"]
s = filter(r->r.Treatment in list &&
    r.Trial < 61,
    streaks)
union(streaks[:,:Phase])
