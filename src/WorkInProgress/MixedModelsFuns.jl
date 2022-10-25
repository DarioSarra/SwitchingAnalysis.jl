"""
    run linear mixed model to explain `var` as a linear function of Protocol
    only on `df` data belonging to `treatment`. The value "Control" is used for general behavior.
    To test it performs MixedModels.likelihoodratiotest between
    `var` ~ 1 + (1|MouseID)
    `var` ~ 1 + Protocol + (1|MouseID)
    returns full model and likelihood ratio test
"""

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

"""
    test_drugs(df,var)
    run linear mixed model to explain `var` as a linear function of Protocol and
    Treatment. Control data are collapsed and treatment are categorical

    To test QUANTITATIVE EFFECTS it performs MixedModels.likelihoodratiotest between
    `var` ~ 1 + Protocol + (1|MouseID)
    `var` ~ 1 + Protocol + Treatment + (1|MouseID)`

    To test QUALITATIVE EFFECTS it performs MixedModels.likelihoodratiotest between
    `var` ~ 1 + Protocol + Treatment + (1|MouseID)`
    `var` ~ 1 + Protocol * Treatment + (1|MouseID)`

    returns models and likelihood ratio tests in ascending order of parameters
"""

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

## New function with variable formulas
function make_formula(r,x1,x2,g = :MouseID)
    term(r) ~ term(1) + term(x1) + term(x2) + term(x1) & term(x2) +
        (term(1)|term(g))+(term(x1)|term(g))+(term(x2)|term(g)) + (term(x1)&term(x2)|term(g))
end

function fit_formula(df,r,x1,x2,g, contrasts)
    f = make_formula(r,x1,x2,g)
    fit!(LinearMixedModel(f,df;contrasts))
end

function plot_effects(df,r,x1,x2,g, contrasts; kwargs...)
    mod = fit_formula(df,r,x1,x2,g, contrasts)
    design = Dict(x1 => unique(df[:, x1]),
            x2 => unique(df[:,x2]))
    eff = effects(design,mod)
    sort!(eff_feed,:)

    # r = 1:1:length(unique(df[:,g]))
    # pos = r .- median(r)
    # dodge_dict = Dict(t=>p for (t,p) in zip(unique(df[:,g]),pos))
    # transform!(eff, [x1,g] =>
    #     ByRow((x1_val, g_val) -> get(dodge_dict, g_val, 0) + x1_val) => :Dodge)

    if any([x1,x2] .== :Treatment)
        Drug_colors!(eff)
        plt =  @df eff scatter(cols(x1), cols(r), group = cols(x2),
            yerror = :err, color = :color; kwargs...)
    else
        plt =  @df eff scatter(cols(x1), cols(r), group = cols(x2),
            yerror = :err; kwargs...)
    end
    return plt, eff, mod
end

function plot_coefficients(df,r,x1,x2,g, contrasts; kwargs...)
    mod = fit_formula(df,r,x1,x2,g, contrasts)
end

function plot_model_estimates(mod)
    np_coef = DataFrame(Variable = replace.(fixefnames(mod),"(centered: 0.75)"=>"", "Treatment: "=>""),
        Coef = coef(mod),
        Error = stderror(mod))

    np_coef[!,:Values] = [contains(r.Variable, "Protocol") ?
        contains(r.Variable, "&") ?
            (r.Coef + np_coef[2,:Coef]) * 0.75 + np_coef[1,:Coef] :
            r.Coef * 0.75 + np_coef[1,:Coef] :
            contains(r.Variable,"Intercept") ?
                r.Coef :
                r.Coef + np_coef[1,:Coef] + np_coef[2,:Coef] * 0.75
        for r in eachrow(np_coef)]
    np_coef = np_coef[2:end,:]
    np_coef[!,:Variables] = [n == "(Intercept)" ? n : n == "Protocol" ? " Baseline" :
        contains(n, "Protocol") ?
        replace(n,"Protocol & " => "") * " Mult." : n * " Add." for n in np_coef.Variable]
    sort!(np_coef,:Variables)
    np_coef[!,:Color] = [get(drug_colors,replace(v," Mult." => "", " Add." => ""), RGB(0.0,0.0,0.0)) for v in np_coef.Variables]
    @df np_coef[1:end,:] scatter(:Variables, :Values, yerr = :Error,
        xrotation = 45, size = (600,1000), color = :Color,
        ylabel = "Pokes number model's  prediction", legend = false)
    hspan!([np_coef[1,:Values]+np_coef[1,:Error], np_coef[1,:Values]-np_coef[1,:Error]], fillalpha = 0.3, color = :grey)
end
