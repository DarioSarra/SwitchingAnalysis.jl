function summarize(dd::AbstractDataFrame,Xvar::Symbol,Yvar::Symbol; Err = :MouseID)
    ErrGroups = vcat(Xvar,Err)
    XaxisGroups = vcat(Xvar)
    pre_err = by(dd, ErrGroups) do df
        (Mean = mean(df[:,Yvar]),)
    end
    with_err = by(pre_err,XaxisGroups) do df
        (Mean = mean(df.Mean), SEM = sem(df.Mean))
    end
    rename(with_err, Xvar=>:Xaxis)
end

function StatsBase.ecdf(dd::AbstractDataFrame,Xvar::Symbol; Err = :MouseID)
    pre_err = by(dd, Err) do df
        F = ecdf(df[:,Xvar])
        (AN = F(F.sorted_values),Xaxis = F.sorted_values)
    end
    pre_err = flatten(pre_err,:AN)

    with_err = by(pre_err,:Xaxis) do df
        (Mean = mean(df.AN), SEM = sem(df.AN))
    end
    sort!(with_err,:Xaxis)
    dropnan!(with_err)
    return with_err
end
