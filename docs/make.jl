using Documenter, SwitchingAnalysis

makedocs(;
    modules=[SwitchingAnalysis],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/DarioSarra/SwitchingAnalysis.jl/blob/{commit}{path}#L{line}",
    sitename="SwitchingAnalysis.jl",
    authors="DarioSarra",
    assets=String[],
)

deploydocs(;
    repo="github.com/DarioSarra/SwitchingAnalysis.jl",
)
