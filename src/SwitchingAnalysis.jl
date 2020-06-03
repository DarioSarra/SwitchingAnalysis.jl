module SwitchingAnalysis

using Reexport
@reexport using DataFrames, CSV, Statistics, StatsBase, StatsPlots, KernelDensity, HypothesisTests
using GLM

export mac_gdrive, linux_gdrive, files_dir, figs_dir, columns_types
export drug_colors, protocol_colors, Treatment_dict
export Prew, Poutcome, Pobservations, Pprotocol, Pnext
export wilcoxon
export process_streaks
export dropnan, dropnan!, Protocol_colors!, Drug_colors!, jump_missing, jump_NaN
export conf_ints, trim_conf_ints, trim_conf_ints!
export KDensity, trim_dist, trim_dist!
export summarize, effect_size, MVT, MVT_scatter, plot_wilcoxon, WebersLaw, plot_wilcoxon_odc, plot_odc
export ODC

include("constants.jl")
include("process_streaks.jl")
include("SignedRank_analysis.jl")
include("plotting_functions.jl")
include("probabilities.jl")
include("utilities.jl")
include("KDensity.jl")
include("Omission_Duty_Cycle.jl")

end # module
