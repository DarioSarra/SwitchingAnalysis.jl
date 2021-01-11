module SwitchingAnalysis

using Reexport
@reexport using DataFrames, CSV, Statistics, StatsBase, StatsPlots, KernelDensity, HypothesisTests
@reexport using GLM, MixedModels
using Distributions

export mac_gdrive, linux_gdrive, files_dir, figs_dir, columns_types
export drug_colors, protocol_colors, Treatment_dict, Plotting_position
export Prew, Poutcome, Pobservations, Pprotocol, Pnext
export wilcoxon
export process_streaks
export dropnan, dropnan!, Protocol_colors!, Drug_colors!, jump_missing, jump_NaN, skipmean,binquantile
export conf_ints, trim_conf_ints, trim_conf_ints!
export KDensity, trim_dist, trim_dist!
export summarize, effect_size, MVT, MVT_scatter, plot_wilcoxon, WebersLaw, plot_wilcoxon_odc, plot_odc, odc_regression, plot_deltafromrew, plot_QODC
export ODC, calculate_odc
export Likelyhood_Ratio_test

include("constants.jl")
include("process_streaks.jl")
include("SignedRank_analysis.jl")
include("plotting_functions.jl")
include("probabilities.jl")
include("utilities.jl")
include("KDensity.jl")
include("Omission_Duty_Cycle.jl")
include("DOFtests.jl")

end # module
