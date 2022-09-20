module SwitchingAnalysis

using Reexport
@reexport using DataFrames, CSV, CategoricalArrays, Random, Dates
@reexport using Statistics, StatsBase,Plots, StatsPlots, KernelDensity, HypothesisTests
@reexport using MixedModels, GLM
@reexport using StandardizedPredictors, Effects
@reexport using Survival

using Distributions

export mac_gdrive, linux_gdrive, files_dir, figs_dir, columns_types
export drug_colors, protocol_colors, Treatment_dict, Plotting_position
export Prew, Poutcome, Pobservations, Pprotocol, Pnext
export dropnan, dropnan!, Protocol_colors!, Drug_colors!, jump_missing, jump_NaN, skipmean,binquantile, TimeFromLeaving
export conf_ints, trim_conf_ints, trim_conf_ints!
export process_streaks
export count_cases, count_bouts!, process_bouts
export CIq, wilcoxon
export mediansurvival_analysis, survivalrate_algorythm, hazardrate_algorythm, function_analysis, KaplanMeier, survival_analysis
export KDensity, trim_dist, trim_dist!
export ODC, calculate_odc
export Likelyhood_Ratio_test
export summarize, effect_size, MVT, MVT_scatter, plot_wilcoxon, WebersLaw, plot_wilcoxon_odc, plot_odc, odc_regression, plot_deltafromrew, plot_QODC
export MVTprediction, testMVT_AvLeave, testMVT_Prot, plotMVT_AvLeave, plotMVT_Prot

include("constants.jl")
include("process_bouts.jl")
include("process_streaks.jl")
include("SignedRank_analysis.jl")
include("survival_analysis.jl")
include("plotting_functions.jl")
include("probabilities.jl")
include("utilities.jl")
include("KDensity.jl")
include("Omission_Duty_Cycle.jl")
include("DOFtests.jl")
include("MVTpredictions.jl")

end # module
