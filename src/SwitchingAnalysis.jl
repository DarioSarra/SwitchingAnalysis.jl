module SwitchingAnalysis

using Reexport
@reexport using DataFrames, CSV, StatsBase, StatsPlots

export files_dir, figs_dir, columns_types, drug_colors, protocol_colors
export summarize
export Prew
export dropnan, dropnan!, Protocol_colors!

include("constants.jl")
include("plotting_functions.jl")
include("probabilities.jl")
include("utilities.jl")

end # module
