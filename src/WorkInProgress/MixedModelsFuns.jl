```
    run linear mixed model to explain 'var' as a linear function of Protocol
    only on 'df' data belonging to 'treatment'. The value "Control" is used for general behavior.
    To test it performs MixedModels.likelihoodratiotest between
    'var' ~ 1 + (1|MouseID)
    'var' ~ 1 + Protocol + (1|MouseID)
    returns full model and likelihood ratio test
```

function test_perprotocol(df,var, treatment)
    df0 = filter(r-> r.Treatment == treatment , df)
    nrow(df0) == 0 && error("filtered out everything")
    df0.Y = df0[:,var]
    f0 = @formula (Y ~ 1 + (1|MouseID))
    m0 = fit(MixedModel, f0, df0)
    f1 = @formula (Y ~ 1 + Protocol + (1|MouseID))
    m1 = fit(MixedModel, f1, df0)
    MixedModels.likelihoodratiotest(m0, m1), m1
end

```
    test_drugs(df,var)
    run linear mixed model to explain 'var' as a linear function of Protocol and
    Treatment. Control data are collapsed and treatment are categorical

    To test QUANTITATIVE EFFECTS it performs MixedModels.likelihoodratiotest between
    'var' ~ 1 + Protocol + (1|MouseID)
    'var' ~ 1 + Protocol + Treatment + (1|MouseID)'

    To test QUALITATIVE EFFECTS it performs MixedModels.likelihoodratiotest between
    'var' ~ 1 + Protocol + Treatment + (1|MouseID)'
    'var' ~ 1 + Protocol * Treatment + (1|MouseID)'

    returns models and likelihood ratio tests in ascending order of parameters
```

function test_drugs(df,var)
    df1 = transform(df, var => :Y)
    m1 = fit!(LinearMixedModel(@formula(Y ~ 1 + Protocol + (1|MouseID)),df1))
    m2 = fit!(LinearMixedModel(@formula(Y ~ 1 + Protocol + Treatment + (1|MouseID)),df1))
    m3 = fit!(LinearMixedModel(@formula(Y ~ 1 + Protocol * Treatment + (1|MouseID)),df1))
    l1 = MixedModels.likelihoodratiotest(m1,m2)
    l2 = MixedModels.likelihoodratiotest(m2,m3)
    println("Quantitative effect p = l1.pvalues[1] \n Qualitative effect p = l2.pvalues[1]")
    return m1, m2, m3, l1, l2
end
