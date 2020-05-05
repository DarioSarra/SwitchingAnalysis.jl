module SwitchingAnalysis

using Reexport
@reexport using DataFrames, CSV, StatsBase, StatsPlots

export files_dir, columns_types, color_dict
export prepare_df
export Prew
export dropnan, dropnan!

include("constants.jl")
include("plotting_functions.jl")
include("probabilities.jl")
include("utilities.jl")

end # module
