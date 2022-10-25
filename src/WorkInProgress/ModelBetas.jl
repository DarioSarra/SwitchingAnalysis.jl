##
r,x1,x2,g = :Num_pokes,:Protocol,:Treatment,:MouseID
mod = Alt_mod_np
mod.formula.lhs
mod.formula

c_df = DataFrame(coeftable(mod))


##
find_additive(coef_df) = Float64.(.!contains.(coef_df.Name, "centered") .&& .!contains.(coef_df.Name, "(Intercept)"))
intercept_val(coef_df) = coef_df[findfirst(contains.(coef_df.Name, "(Intercept)")),Symbol("Coef.")]
function set_baseline(coef_df; mode = "centered")
    if mode == "centered"
        base = intercept_val(coef_df) .+ multiplicative_effects(coef_df)
    elseif mode == "intercept"
        base = intercept_val(coef_df)
    end
    return base
end

additive_effects(coef_df; mode = "centered") = find_additive(coef_df) .* coef_df[:, Symbol("Coef.")] .+
    find_additive(coef_df) .* set_baseline(coef_df,mode = mode)

function center_val(str::String)
    valstart = last(findfirst("centered: ",str))
    valend = last(findfirst(")", pre_coef_df[2,:Name]))
    parse(Float64,str[valstart+1:valend-1])
end
find_multiplicative(coef_df) = contains.(coef_df.Name, "centered") .&& .!contains.(coef_df.Name," & ")
take_multiplicative(coef_df) = [contains(r.Name, "centered") && !contains(r.Name," & ") ? center_val(r.Name) : 0.0 for r in eachrow(coef_df)]
multiplicative_effects(coef_df) = take_multiplicative(coef_df) .* coef_df[:, Symbol("Coef.")] .+  find_multiplicative(coef_df) .* intercept_val(coef_df)


find_interactions_center(coef_df) = [contains(r.Name, "centered") && contains(r.Name," & ") ? center_val(r.Name) : 0.0 for r in eachrow(coef_df)]
find_first_regressor(str) = s[1:first(findfirst(" & ", str))-1]
function find_interactions_baseline(coef_df)
    v = zeros(nrow(coef_df))
    idxs = findall(contains.(coef_df.Name, "centered") .&& contains.(coef_df.Name," & "))
    for i in idxs
        s = coef_df[i,:Name]
        regressor_idx = findfirst(coef_df.Name .== find_first_regressor(s))
        v[i] =  coef_df[regressor_idx, Symbol("Coef.")]
    end
    return v
end
find_interactions(coef_df) = contains(coef_df.Name, "centered") && contains(coef_df.Name," & ")
interaction_effects(coef_df) = (find_interactions_baseline(coef_df) .+ coef_df[:, Symbol("Coef.")] .+ intercept_val(coef_df)) .* find_interactions_center(df0)


function calculate_effects(coef_df; mode = "centered")
        additive_effects(coef_df, mode = mode) .+ multiplicative_effects(coef_df) .+ interaction_effects(df0)
end

function calculate_effects!(coef_df, mode = "centered")
    coef_df[!,:Effects] = calculate_effects(coef_df, mode = mode)
end
##
calculate_effects(c_df)
calculate_effects!(c_df)
open_html_table(c_df)
@df c_df scatter(:Name, :Effects, yerror = cols(3))


c_df = pre_coef_df
additive_effects(c_df)
multiplicative_effects(c_df)
interaction_effects(c_df)
