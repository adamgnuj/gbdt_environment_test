#CRPS score integrate module
module Julia_CRPS_Scoring

using DataFrames, StatsBase
using Integrals,Distributions, Statistics

export CRPS_distribution, CRPS_ecdf



struct PointWeightRV
    loc
end

Distributions.cdf(rv::PointWeightRV, x) = x < rv.loc ? 0 : 1
Statistics.quantile(rv::PointWeightRV, q) = rv.loc

"""
crps(rv, obs)
"""
function CRPS(cdf, obs, lb, ub)
    obs = Float64(obs)
    
    f(x, p) = (cdf(x))^2 ##cdf
    prob = IntegralProblem(f, lb, obs)
    sol = solve(prob, QuadGKJL())
    sollhs = sol.u 

    g(x, p) = (1.0 - cdf(x))^2
    prob = IntegralProblem(g, float(obs),  max(ub, obs))

    solrhs = solve(prob, QuadGKJL()).u

    sollhs + solrhs
end

function fit_inverse_gamma(loc, var)
    
    if var == 0 return PointWeightRV(loc) end
        
    α = loc^2 / var + 2
    β = loc * (α - 1)
    InverseGamma(α, β)
end


function CRPS_distribution(loc, var, y_val, distr = "InverseGamma")    
    if distr == "InverseGamma"
        rvs = fit_inverse_gamma.(loc, var)
    elseif distr == "Normal"
        rvs = Normal.(loc, sqrt.(var))
    else
        throw(error("$distr distribution CRPS is not implemented")) 
    end
    cdfs = [x -> cdf(rv, x) for rv in rvs]
    
    tol = 1e-7
    lbs = Float64.(quantile.(rvs, tol))
    ubs = Float64.(quantile.(rvs, 1.0 - tol))
    CRPS.(cdfs, y_val, lbs, ubs)
end

function CRPS_ecdf(samples, y_val)
    cdfs = ecdf.(eachrow(samples))
    lbs = Float64.(minimum.(eachrow(samples)))
    ubs = Float64.(maximum.(eachrow(samples)))
    CRPS.(cdfs, y_val, lbs, ubs)
end



end