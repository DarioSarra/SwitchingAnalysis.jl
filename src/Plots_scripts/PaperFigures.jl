include("filtering.jl");
gr(size=(600,600), tick_orientation = :out, grid = false,
    linecolor = :black,
    markerstrokecolor = :black,
    thickness_scaling = 2,
    markersize = 6)
################################ Poke and Travel analysis ##################################
list = ["PreVehicle",
    "Altanserin",
    "SB242084",
    "Way_100135",
    "Methysergide",
    "Citalopram",
    "SB242084_opt",
    "Saline"]
filter!(r->r.Treatment in list &&
    r.Trial < 51 &&
    r.MouseID != "pc7",
    streaks)
streaks[streaks.Treatment .== "PreVehicle",:Treatment] .= "Control"
streaks[streaks.Treatment .== "Saline",:Treatment] = [o ? "Optogenetic" : "Control" for o in streaks[streaks.Treatment .== "Saline",:Stim]]
streaks[streaks.Treatment .== "SB242084_opt",:Phase] .=  "SB242084_opt"
streaks[streaks.Treatment .== "SB242084_opt",:Treatment] = [o ? "SB242084_opt" : "Control" for o in streaks[streaks.Treatment .== "SB242084_opt",:Stim]]
streaks[!,:ROILeavingTime] = streaks.Stop_trial .- streaks.Stop_poking
################################ Prew at leaving ##################################

gd1 = groupby(streaks,[:Protocol,:MouseID,:Phase,:Treatment])
df1 = combine(gd1, :Num_pokes => mean => :Num_pokes, :AfterLast => mean => :AfterLast,:Actual_Leaving_Prew => mean => :Leaving_Prew)

gd2 = groupby(df1,[:Protocol,:Treatment])
df2 = combine(gd2, :Num_pokes => mean, :Num_pokes => sem, :AfterLast => mean, :AfterLast => sem, :Leaving_Prew => mean, :Leaving_Prew => sem)
filt_2 = filter(r->r.Treatment == "Control",df2)
sort!(filt_2, :Protocol)
@df filt_2 scatter(:Protocol, :Num_pokes_mean, yerror = :Num_pokes_sem, label = false, xlims = (0.25,2.75))
@df filt_2 scatter(:Protocol, :AfterLast_mean, yerror = :AfterLast_sem, label = false, xlims = (0.25,2.75))
@df filt_2 scatter(:Protocol, :Leaving_Prew_mean, yerror = :Leaving_Prew_sem,label = false, xlims = (0.25,2.75), ylims =(0,1))

gd3 = groupby(df1,[:Protocol,:Phase,:Treatment])
df3 = combine(gd2, :Leaving_Prew => mean, :Leaving_Prew => sem)
##

df3 = filter(r->r.Treatment == "Control", df2)

vp = [@df d bar(:Protocol, :Leaving_Prew_mean, yerror = :Leaving_Prew_mean, ylims =(0,1)) for d in groupby(df3,:Phase)]
@df df3 scatter()
plot(vp[1])
plot(vp[2])
plot(vp[3])
