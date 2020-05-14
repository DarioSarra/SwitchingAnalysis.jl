module SwitchingAnalysis

using Reexport
@reexport using DataFrames, CSV, StatsBase, StatsPlots, KernelDensity, HypothesisTests
using GLM

export mac_gdrive, linux_gdrive, files_dir, figs_dir, columns_types
export drug_colors, protocol_colors, Treatment_dict
export Prew, Poutcome, Pobservations, Pprotocol, Pnext
# export Pobservations_lastval, Pprotocol_lastval, Pnext_lastval
export process_streaks
export dropnan, dropnan!, Protocol_colors!, Drug_colors!, jump_missing, jump_NaN
export conf_ints, trim_conf_ints, trim_conf_ints!
export KDensity, trim_dist, trim_dist!
export summarize, MVT, MVT_scatter, MVT_meanInstRew

include("constants.jl")
include("process_streaks.jl")
include("plotting_functions.jl")
include("probabilities.jl")
include("utilities.jl")
include("KDensity.jl")

end # module
