```@meta
DocTestSetup = :(using Unitful, UnitfulBrewing)
```

# UnitfulBrewing.jl

A supplemental units package for [Unitful.jl](https://github.com/JuliaPhysics/Unitful.jl), with the units used in beer brewing: sugar content and gravity, color, bitterness, diastatic power, carbonation, pH, and US, imperial and culinary volumes.

It also defines *equivalences*, via [UnitfulEquivalences.jl](https://github.com/sostock/UnitfulEquivalences.jl), for converting between quantities that measure different things but are commonly used interchangeably in brewing, such as degrees Plato and specific gravity.

!!! note
    This package is still under development and not yet registered.

## Installation

Since the package is not registered yet, install it from its repository:

```julia
using Pkg
Pkg.add(url = "https://github.com/JuliaBrewing/UnitfulBrewing.jl")
```

## Quick start

Load Unitful together with UnitfulBrewing. The brewing units are then available through Unitful's `u"..."` string macro, like any other unit:

```jldoctest
julia> using Unitful, UnitfulBrewing

julia> float(uconvert(u"l", 5u"gal"))
18.92705892 L

julia> uconvert(u"EBC", 10u"SRM")
197//10 EBC

julia> uconvert(u"sg", 12u"°P", SugarGravity())
1.048582995951417 sg

julia> uconvert(u"g/l", 2.5u"vols", CarbonationDensity())
4.9425 g L⁻¹
```

## Contents

- [Dimensions and units](units.md) lists the dimensions and units this package defines.
- [Equivalences](equivalences.md) describes the conversions between related quantities, with the formulas they use.
- [API reference](api.md) documents the exported equivalence types and the internal conversion functions.

## License

This package is licensed under the [MIT license](https://github.com/JuliaBrewing/UnitfulBrewing.jl/blob/main/LICENSE).
