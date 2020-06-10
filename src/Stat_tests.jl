function LoglikelihoodRatioTest(simple_model, full_model)
    degrees = abs(dof(simple_model) - dof(full_model))
    ccdf(Chisq(degrees), deviance(simple_model) - deviance(full_model))
end


function AICTest(candidate_model, simpler_model)
    exp((aic(candidate_model) - aic(simpler_model))/2)
end
function AICc(model)
    aic(model) + ((2*(dof(model)^2) + 2*dof(model))/(nobs(model) - dof(model) - 1))
end
function AICcTest(candidate_model, simpler_model)
    exp((AICc(candidate_model) - AICc(simpler_model))/2)
end
