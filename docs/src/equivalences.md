```@meta
DocTestSetup = :(using Unitful, UnitfulBrewing)
```

# Equivalences

Some quantities used in brewing measure different things but are commonly treated as interchangeable, according to well-established relations. Degrees Plato and specific gravity are the typical example: the first is a mass fraction of sugar and the second a ratio of densities, but both estimate the amount of fermentables in the wort.

Since these quantities have different dimensions, Unitful does not convert between them directly. Instead, UnitfulBrewing defines *equivalences*, using [UnitfulEquivalences.jl](https://github.com/sostock/UnitfulEquivalences.jl). An equivalence is passed as the last argument of `uconvert`:

```julia
uconvert(target_unit, quantity, equivalence)
```

## Sugar contents and gravity

Two equivalences relate degrees Plato (dimension `𝐒𝐂`) to specific gravity and gravity units.

[`SugarGravity`](@ref) uses the rational relation

```math
\text{Plato} = 259\left(1 - \frac{1}{\text{sg}}\right).
```

[`SugarGravityQuad`](@ref) uses the quadratic relation

```math
\text{Plato} = 668.72\,\text{sg} - 463.37 - 205.35\,\text{sg}^2,
```

which, in gravity units ``\text{gu} = 1000(\text{sg} - 1)``, reads

```math
\text{Plato} = 0.25802\,\text{gu} - 0.00020535\,\text{gu}^2.
```

Both work in either direction and with any of the units `°P`, `Brix`, `Balling`, `sg` and `gu`:

```jldoctest
julia> uconvert(u"°P", 1.040u"sg", SugarGravity())
9.961538461538483 °P

julia> uconvert(u"sg", 10u"°P", SugarGravity())
1.0401606425702812 sg

julia> uconvert(u"gu", 10u"°P", SugarGravityQuad())
40.032121145872225 gu

julia> uconvert(u"°P", 1.048u"sg", SugarGravityQuad())
11.911833600000001 °P
```

In the range of interest for brewing, from 0 °P to about 30 °P, the two equivalences differ by less than 0.4%.

## Density and concentration

For water-based solutions with small amounts of solutes, as in brewing water treatment, a concentration of 1 ppm (by mass) is treated as equivalent to 1 mg/l. [`DensityConcentration`](@ref) implements this, relating any dimensionless concentration (`ppm`, `ppb`, `percent`, …) to a mass per volume:

```jldoctest
julia> uconvert(u"mg/l", 10u"ppm", DensityConcentration())
10 mg L⁻¹

julia> uconvert(u"ppm", 1u"g/l", DensityConcentration())
1000.0 ppm
```

## Carbonation and density

Carbonation is usually given in volumes of CO₂ per volume of beer (`vols`), but sometimes as the mass of dissolved CO₂ per volume, in g/l. [`CarbonationDensity`](@ref) relates these using the density of CO₂ at 0 °C and 1 atm, so that 1 vols is equivalent to 1.977 g/l:

```jldoctest
julia> uconvert(u"g/l", 2.5u"vols", CarbonationDensity())
4.9425 g L⁻¹

julia> uconvert(u"vols", 5u"g/l", CarbonationDensity())
2.529084471421345 vols
```

## Not yet implemented

- An equivalence between bitterness in `IBU` and the concentration of iso-alpha acids in mg/l, with 1 IBU equivalent to 1 mg/l.
- Volumes of gases other than CO₂, such as N₂ for nitro beers.
