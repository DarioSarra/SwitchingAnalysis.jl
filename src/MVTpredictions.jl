function MVTprediction(s_df)
    firstMVT = testMVT_AvLeave(s_df)
    firstplt = plotMVT_AvLeave(s_df)

    secondMVT = testMVT_Prot(s_df, :Num_pokes)
    secondplt = plotMVT_Prot(s_df,:Num_pokes)
    # shuffle_secondplt = plotMVT_Prot(s_df,:Shuffle_Num_pokes)

    thirdMVT = testMVT_Prot(s_df, :Leaving_NextPrew)#:Leaving_Prew
    thirdplt = plotMVT_Prot(s_df,:Leaving_NextPrew)#:Leaving_Prew
    # shuffle_thirdplt = plotMVT_Prot(s_df,:Shuffle_Leaving_NextPrew)

    # plt = plot(firstplt, plot(axis = false, xticks = false, yticks = false),
    #     secondplt, shuffle_secondplt,
    #     thirdplt, shuffle_thirdplt,
    #     layout = (3,2), size = (1600,2400))
    plt = plot(firstplt,# plot(axis = false, xticks = false, yticks = false),
        secondplt, #shuffle_secondplt,
        thirdplt, #shuffle_thirdplt,
        layout = (3,1), size = (1600,2400))

    return (AvLeave = firstMVT, PokesProt = thirdMVT, LeaveProt = secondMVT,
        Plot = plt, AvLeave_plt = firstplt, ProtLeave_plt = secondplt, ProtPokes_plt = thirdplt)
end

function testMVT_AvLeave(s_df)
    testAvLeave = wilcoxon(s_df,:AverageRewRate, :Leaving_NextPrew; f = x -> mean(skipmissing(x)))
    testAvLeave.P[1]
end

function testMVT_Prot(s_df, y)
    dd = DataFrame(s_df)
    dd.Y = dd[:,y]
    f0 = @formula (Y ~ 1 + (1|MouseID))
    m0 = fit(MixedModel, f0, dd)
    f1 = @formula (Y ~ 1 + Protocol + (1|MouseID))
    m1 = fit(MixedModel, f1, dd)
    secondMVT = MixedModels.likelihoodratiotest(m0, m1)
    secondMVT.pvalues[1]
end

function plotMVT_AvLeave(s_df)
    df0 = combine(groupby(s_df, :MouseID),
        :Leaving_NextPrew => mean,
        :AverageRewRate => mean)
    df1 = DataFrame(Label = ["Average", "Leaving"],
        Pos = [1,2],
        Mean = [mean(df0.AverageRewRate_mean),mean(df0.Leaving_NextPrew_mean)],
        SEM = [sem(df0.AverageRewRate_mean),sem(df0.Leaving_NextPrew_mean)])
    @df df1 bar(:Pos, :Mean, yerror = :SEM, xticks = (:Pos,:Label),
        legend = false, color = :grey, xlims = (0.5,2.5))
end


# function plotMVT_Prot(s_df,y)
#     df0 = combine(groupby(s_df, [:MouseID, :Protocol]),
#         y => mean => y)
#     df1 = combine(groupby(df0, :Protocol),
#         y .=> [mean, sem] .=> [:Mean, :SEM])
#     Protocol_colors!(df1)
#     sort!(df1,:Protocol)
#     plt = @df df1 bar(:Protocol, :Mean, yerror = :SEM,
#         legend = false, color = :color, xticks = 0.5:0.25:1, xlims = (0.3,1.2),
#         xlabel = "Patch quality", size = (1200,600))
#     max_y = maximum(df1.Mean) + maximum(df1.SEM)
#     return plt, max_y
# end

function plotMVT_Prot(s_df,y)
    s_y = Symbol("Shuffle_"*string(y))
    df0 = combine(groupby(s_df, [:MouseID, :Protocol]),
        y => mean => y,
        s_y => mean => s_y)
    df1 = combine(groupby(df0, :Protocol),
        y .=> [mean, sem] .=> [:Mean, :SEM])
    Protocol_colors!(df1)
    df2 = combine(groupby(df0, :Protocol),
        s_y .=> [mean, sem] .=> [:Mean, :SEM])
    Protocol_colors!(df2)
    df2.Protocol = df2.Protocol .+ 1
    append!(df1,df2)
    sort!(df1,:Protocol)
    plt = @df df1 bar(:Protocol, :Mean, yerror = :SEM,
        legend = false, color = :color, xticks = 0.5:0.25:1, xlims = (0.3,2.2),
        xlabel = "Patch quality")
    # max_y = maximum(df1.Mean) + maximum(df1.SEM)
    return plt#, max_y
end
