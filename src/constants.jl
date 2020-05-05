const files_dir = "/home/beatriz/mainen.flipping.5ht@gmail.com/Flipping/Datasets/Pharmacology/SwitchingData/Results"

const columns_types = Dict(
    :Protocol => Union{String,Missing},
    )

const color_dict = Dict(
    "Altanserin" => RGB(0.6,0.149,0.561),
    "SB242084" => RGB(0.902,0.604,0.737),
    "Citalopram" => RGB(0.1216,0.4667,0.7059),#RGB(0.0902,0.7451,0.8118)
    "Methysergide" => RGB(0.1725,0.6275,0.1725),
    "Way_100135" => RGB(1.0,0.498,0.0549),
    "training" => RGB(0.498,0.498,0.498),
    )
