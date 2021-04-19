include("filtering.jl");
##
list = ["PreVehicle",
    "Altanserin",
    "SB242084",
    "Way_100135",
    "Methysergide",
    "Citalopram",
    "SB242084_opt",
    "Saline"]
s = filter(r->r.Treatment in list &&
    r.Trial < 51 &&
    # r.Trial_Travel_to < 40 &&
    r.MouseID != "pc7",
    streaks)
b = filter(r->r.Treatment in list &&
    r.Trial < 51 &&
    # r.Trial_Travel_to < 40 &&
    r.MouseID != "pc7",
    bouts)
for df in [s,b]
    df[df.Treatment .== "PreVehicle",:Treatment] .= "Control"
    df[df.Treatment .== "Saline",:Treatment] = [o ? "Optogenetic" : "Control" for o in df[df.Treatment .== "Saline",:Stim]]
    df[df.Treatment .== "SB242084_opt",:Phase] .=  "SB242084_opt"
    df[df.Treatment .== "SB242084_opt",:Treatment] = [o ? "SB242084_opt" : "Control" for o in df[df.Treatment .== "SB242084_opt",:Stim]]
end
##
#look at survival function without censor data. That is looking only at last bout in a trial, not bout interrupted by a reward
simplesurv = filter(r-> r.Omissions_plus_one >= 2 &&
    r.Leave,b)
