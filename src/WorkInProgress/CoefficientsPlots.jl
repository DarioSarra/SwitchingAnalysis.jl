include.(["filtering.jl","TtestFuns.jl","MixedModelsFuns.jl","PlotsFuns.jl"]);
using Dates, Revise
gr(size=(600,600), tick_orientation = :out, grid = false,
    linecolor = :black,
    markerstrokecolor = :black,
    thickness_scaling = 2,
    markersize = 6)
#=
In setting the constrast matrix we can use:
    - dummy coding to test if a level differs from the reference level
    - effects coding to test if it differs from the mean across levels
=#
contrasts = Dict(
    :Protocol => Center(0.75),
    :Treatment => DummyCoding(; base="Control"), #this tests whether a level differs from the reference level
    :MouseID => Grouping())
##
list = ["Altanserin","Control"]
Alt = filter(r->r.Phase in list &&
    r.Treatment in list,streaks)

Alt_NP_model = fit_formula(Alt,:Num_pokes,:Protocol,:Treatment,:MouseID, contrasts)
##
iscategorical(s) = contains(s,": ") && !contains(s, "centered:") && !contains(s, "(Intercept)")
iscontinuous(s) = contains(s, "centered:") && !contains(s," & ") && !contains(s, "(Intercept)")
isinteraction(s) = contains(s," & ") && contains(s, "centered:") && contains(s, "centered:")
isintercept(s) = s == "(Intercept)"
function center_val(str::String)
    valstart = last(findfirst("centered: ",str))
    valend = last(findfirst(")", pre_coef_df[2,:Name]))
    parse(Float64,str[valstart+1:valend-1])
end
function find_regressor(s)
    r = match(r"centered: ",s)
    ending = findnext(')',s,r.offset)
    beginning = isnothing(findprev(' ',s,r.offset)) ? 1 : findprev(' ',s,r.offset)
    s[beginning:ending]
end
##
function extract_betas(df)
    v = Float64[]
    for r in eachrow(df)
        if iscategorical(r.Name)
            res = r[Symbol("Coef.")]
        elseif iscontinuous(r.Name)
            res = r[Symbol("Coef.")] * center_val(r.Name)
        elseif isinteraction(r.Name)
            orig_param_idx = findfirst(c_df.Name .== find_regressor(r.Name))
            res = (#=df[orig_param_idx,Symbol("Coef.")] +=# r[Symbol("Coef.")]) * center_val(r.Name)
        elseif isintercept(r.Name)
            res = r[Symbol("Coef.")]
        else
            error("Type of regressor not identified for $(r.Name)")
        end
        push!(v,res)
    end
    return v
end
function extract_betas!(df)
    df[!,:CenteredBetas] = extract_betas(df)
    return df
end

function calc_betas(mod::LinearMixedModel)
    c_df = DataFrame(coeftable(mod))
    extract_betas!(c_df)
end

c_df = calc_betas(Alt_NP_model)

@df c_df[2:end,:] scatter(:Name, :CenteredBetas, yerror = cols(Symbol("Std. Error")))
hline!([0,0],linestyle = :dash)
