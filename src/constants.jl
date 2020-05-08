const mac_gdrive = "/Volumes/GoogleDrive/My Drive"
const linux_gdrive = "/home/beatriz/mainen.flipping.5ht@gmail.com"
const files_dir = "Flipping/Datasets/Pharmacology/SwitchingData/Results"
const figs_dir = "Flipping/Datasets/Pharmacology/SwitchingData/Results/figures/"

const columns_types = Dict(
    :Protocol => Union{String,Missing},
    )

const drug_colors = Dict(
    "Altanserin" => RGB(0.6,0.149,0.561),
    "SB242084" => RGB(0.902,0.604,0.737),
    "Citalopram" => RGB(0.1216,0.4667,0.7059),#RGB(0.0902,0.7451,0.8118)
    "Methysergide" => RGB(0.1725,0.6275,0.1725),
    "Way_100135" => RGB(1.0,0.498,0.0549),
    "training" => RGB(0.498,0.498,0.498),
    "PreVehicle" => RGB(0.498,0.498,0.498),
    "PostVehicle" => RGB(0.498,0.498,0.498),
    "Saline" => RGB(0.498,0.498,0.498),
    "None" => RGB(0.498,0.498,0.498),
    )

const protocol_colors = Dict(
    "Low" => RGB(248/255,214/255,21/255),
    "Med." => RGB(242/255,151/255,37/255),
    "High" => RGB(221/255,43/255,41/255),#RGB(0.0902,0.7451,0.8118)
    )
