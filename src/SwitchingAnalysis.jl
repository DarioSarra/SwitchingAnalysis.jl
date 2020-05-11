module SwitchingAnalysis

using Reexport
@reexport using DataFrames, CSV, StatsBase, StatsPlots

export mac_gdrive, linux_gdrive, files_dir, figs_dir, columns_types, drug_colors, protocol_colors
export summarize
export Prew, Poutcome, Pobservations, Pprotocol, Pnext
export Pobservations_lastval, Pprotocol_lastval, Pnext_lastval
export dropnan, dropnan!, Protocol_colors!, Drug_colors!

include("constants.jl")
include("plotting_functions.jl")
include("probabilities.jl")
include("utilities.jl")

end # module
