# Print units as in the REPL on macOS, e.g. `L⁻¹` instead of `L^-1`
ENV["UNITFUL_FANCY_EXPONENTS"] = "true"

using Documenter
using Unitful
using UnitfulBrewing

DocMeta.setdocmeta!(UnitfulBrewing, :DocTestSetup, :(using Unitful, UnitfulBrewing); recursive=true)

makedocs(;
    modules = [UnitfulBrewing],
    sitename = "UnitfulBrewing.jl",
    authors = "Ricardo Rosa",
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", "false") == "true",
        canonical = "https://JuliaBrewing.github.io/UnitfulBrewing.jl",
        edit_link = "main",
    ),
    pages = [
        "Home" => "index.md",
        "Dimensions and units" => "units.md",
        "Equivalences" => "equivalences.md",
        "API reference" => "api.md",
    ],
)

deploydocs(;
    repo = "github.com/JuliaBrewing/UnitfulBrewing.jl",
    devbranch = "main",
    push_preview = false,
)
