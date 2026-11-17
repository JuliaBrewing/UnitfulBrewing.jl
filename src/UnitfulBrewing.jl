"""
    UnitfulBrewing

Module extending [Unitful.jl](https://github.com/JuliaPhysics/Unitful.jl) with
beer brewing units, and with equivalences, via
[UnitfulEquivalences.jl](https://github.com/sostock/UnitfulEquivalences.jl),
between quantities that are used interchangeably in brewing.

The units are available through Unitful's `u"..."` string macro once the
package is loaded, e.g. `u"°P"`, `u"SRM"` or `u"vols"`.

The sources of the definitions and relations are given next to them, in the
docstrings, and in the page "References" of the documentation.
"""
module UnitfulBrewing

using Unitful

using UnitfulEquivalences: Equivalence, dimtype, @eqrelation
import UnitfulEquivalences: edconvert

export DensityConcentration, SugarGravity, SugarGravityQuad, CarbonationDensity

# New dimensions
@dimension 𝐂𝐋   "𝐂𝐋"     Color
@dimension 𝐃𝐏   "𝐃𝐏"     DiastaticPower
@dimension 𝐁𝐓   "𝐁𝐓"     Bitterness
@dimension 𝐒𝐂   "𝐒𝐂"     SugarContents
@dimension 𝐂𝐁   "𝐂𝐁"     Carbonation

# Time units: adding beerjson symbols as alias to Unitful symbols
const sec = Unitful.s
const min = Unitful.minute
const day = Unitful.d
const week = Unitful.wk

# US volumes
# Ref: NIST Handbook 44, Appendix C, "General Tables of Units of Measurement"
# (1 gal = 231 in³ = 4 qt, 1 qt = 2 pt, 1 pt = 16 fl oz); for the beer barrel,
# 27 CFR § 25.11 (TTB): "Barrel. When used as a unit of measure, the quantity equal
# to 31 U.S. gallons".
@unit gal       "gal"       Gallon      231*(Unitful.inch)^3    false
@unit qt        "qt"        Quart       gal//4                  false
@unit pt        "pt"        Pint        qt//2                   false
@unit floz      "floz"      FluidOunce  pt//16                  false
@unit bbl       "bbl"       Barrel      31gal                   false # US beer barrel (not the 42 gal oil barrel)

# Imperial volumes
# Ref: UK Weights and Measures Act 1985, Schedule 1 (1 gallon = 4.54609 dm³,
# 1 gallon = 8 pints = 160 fluid ounces, 1 gill = 1/4 pint). The beer barrel of
# 36 imperial gallons is the traditional British one.
@unit ifloz     "ifloz"     ImperialFluidOunce  28.4130625*(Unitful.mL)  false
@unit gi        "gi"        Gill                5ifloz                  false
@unit ipt       "ipt"       ImperialPint        20ifloz                 false
@unit iqt       "iqt"       ImperialQuart       2ipt                    false
@unit igal      "igal"      ImperialGallon      8ipt                    false
@unit ibbl      "ibbl"      ImperialBarrel      36igal                  false # imperial beer barrel

# Culinary volumes
# Ref: NIST Handbook 44, Appendix C (1 cup = 8 fl oz, 1 tablespoon = 1/2 fl oz,
# 1 teaspoon = 1/6 fl oz).
@unit cup       "cup"       Cup         pt//2                   false
@unit tbsp      "tbsp"      Tablespoon  cup//16                 false
@unit tsp       "tsp"       Teaspoon    tbsp//3                 false


# Sugar content
# Degrees Plato, Brix and Balling are mass percentages of sucrose (or extract) in
# solution, from the tables of Balling (1843), Brix (1854) and Plato (1900s),
# which differ slightly and are taken here as equal.
@refunit °P     "°P"        Plato               𝐒𝐂          false
@unit Brix      "Brix"      Brix                1°P         false
@unit Balling   "Balling"   Balling             1°P         false

# Specific gravity
# uconvert(Unitful.NoUnits, 1.010u"sg") == 1.01
# uconvert(u"permille", 1.040u"sg") == 1040.0 ‰
# uconvert(u"gu", 1.040u"sg") == 40.0 gu
# uconvert(u"sg", 40u"gu") == 1.04 sg
@unit       sg  "sg"        SpecificGravity     1.0         false
@affineunit gu  "gu"        1000.0 * Unitful.permille
const gp = gu # gravity points

# Diastatic Power
# Ref: °WK = 3.5 °Lintner - 16, the usual approximate interconversion of the ASBC
# (°Lintner) and EBC (°WK) values, e.g. G. Oliver (ed.), The Oxford Companion to
# Beer, Oxford University Press, 2011, entry "diastatic power"; Megazyme, data
# sheet E-MASTP, https://prod-docs.megazyme.com/documents/Data_Sheet/E-MASTP_DATA.pdf
@refunit        °Lintner    "°Lintner"  Lintner     𝐃𝐏                  false
@unit           °WK_aux     "°WK_aux"   WK_aux      (10//35)°Lintner    false
@affineunit     °WK         "°WK"       16°WK_aux
const Lintner = °Lintner
const WK = °WK

# Color units
# Refs: SRM (ASBC, adopted in 1950) and EBC are both from the absorbance at 430 nm,
# A430 of a 1 cm cell, as SRM = 12.7 A430 and EBC = 25 A430, hence EBC = (25/12.7)
# SRM ≈ 1.97 SRM (ASBC Methods of Analysis, Beer-10; EBC Analytica). The relation
# SRM = 1.3546 °L - 0.76 is an empirical fit to the EBC and Lovibond values published
# by maltsters, as quoted in the Wikipedia article "Standard Reference Method"; its
# original source was not found.
@refunit    SRM     "SRM"       SRM                 𝐂𝐋                  false      
@unit       EBC     "EBC"       EBC                 (100//197)SRM       false
@unit       L_aux   "L_aux"     L_aux               (13546//10000)SRM    false
@affineunit °L      "°L"        -(7600//13546)L_aux
const srm = SRM
const Lovi = °L
const Lovibond = °L
const ebc = EBC

# Carbonation units
# Volumes of CO₂ (at 0 °C and 1 atm) dissolved per volume of beer, as the
# BeerJSON unit "vols" (BeerJSON schema, https://github.com/beerjson/beerjson)
@refunit    vols    "vols"      VolumesOfCO2        𝐂𝐁                  false

# International Bitterness Unit

@refunit    IBU     "IBU"       InternationalBitternessUnit 𝐁𝐓      false

# Concentration units
#=
Unitful (since v1.19) already defines percent, permille, pertenthousand,
pcm, ppm, ppb, ppt and ppq, so they are not redefined here.
=#

# pH logarithmic scale
@logscale pH⁺    "pH⁺"       powerofHydrogen      10      10      false
const pwrH = pH⁺ # either pH\^+<ESC> or, with dead keys, pH\^<SPACE>+<ESC>
#=
Using symbols pwrH and pH⁺ since there is a dimensional symbol pH already
defined in Unitful:
```julia-repl
julia> typeof(Unitful.pH)
Unitful.FreeUnits{(pH,),𝐋² 𝐌 𝐈⁻² 𝐓⁻²,nothing}
```
=#

## Define the conversion functions between Plato and gravity units
"""
    gu_to_plato(gu::Number)

Convert a value in gravity units to degrees Plato according to the quadratic
formula

    Plato = 0.25802 gu - 0.00020535 gu^2,

which is equivalent to the formula for specific gravity

    Plato = 668.72 sg - 463.37 - 205.35 sg^2,

with `gu = 1000 (sg - 1)`.

This is the relation used by [`SugarGravityQuad`](@ref).

# References

- "On the relationship between Plato and specific gravity", Brewer's Friend, 2012,
  <https://www.brewersfriend.com/2012/10/31/on-the-relationship-between-plato-and-specific-gravity>,
  which attributes this quadratic fit to Robbins (1975); the original publication was not
  found.
"""
gu_to_plato(gu::Number) = 0.25802gu - 0.00020535gu^2

"""
    plato_to_gu(p::Number)

Convert a value in degrees Plato to gravity units by inverting the quadratic
formula of [`gu_to_plato`](@ref), taking the root in the range of interest:

    gu = e - sqrt(e^2 - g p),

where

    e = 0.25802 / (2 × 0.00020535) = 628.2444606768931,
    g = 1 / 0.00020535 = 4869.734599464329.

For `p > e^2 / g ≈ 81.05`, far beyond any wort, the quadratic has no real
inverse, and `e` is returned just for definiteness, although the conversion is
meaningless there.

This is the relation used by [`SugarGravityQuad`](@ref).
"""
function plato_to_gu(p::Number)
    e = 628.2444606768931
    g = 4869.734599464329
    d = e^2 - g*p
    if d >= 0
        e - sqrt(d)
    else
        e
    end
end

# Define the equivalences

"""
    DensityConcentration()

Equivalence to convert between Density and Concentration for water-based
solutions, with relatively small quantities of solutes, as in water treatment,
so that 1 mg/L is equivalent to 1 ppm (parts per million).

This assumes a density of 1 kg/L for the solution: it is the usual convention in
water treatment and brewing water chemistry, accurate to about 0.2% for water at
room temperature.

# Examples

```jldoctest
julia> uconvert(u"mg/l", 10u"ppm", DensityConcentration())
10 mg L⁻¹
julia> uconvert(u"ppm", 1u"g/l", DensityConcentration())
1000.0 ppm
```
"""
struct DensityConcentration <: Equivalence end

@eqrelation DensityConcentration Unitful.Density / Unitful.DimensionlessQuantity = 1u"kg/l"

"""
    CarbonationDensity()

Equivalence to convert between carbonation, in volumes of CO₂ per volume of
beer (`vols`), and the density of dissolved CO₂, using the density of CO₂ at
0 °C and 1 atm, so that 1 vols is equivalent to 1.977 g/L.

# References

- The density of gaseous CO₂ at 0 °C and 1 atm, 1.977 kg/m³, e.g. in the CRC
  Handbook of Chemistry and Physics; it follows from the molar mass 44.009 g/mol.

# Examples

```jldoctest
julia> uconvert(u"g/l", 2.5u"vols", CarbonationDensity())
4.9425 g L⁻¹
julia> uconvert(u"vols", 5u"g/l", CarbonationDensity())
2.529084471421345 vols
```
"""
struct CarbonationDensity <: Equivalence end

@eqrelation CarbonationDensity Unitful.Density / Carbonation = 1.977u"g/l" / vols

"""
    SugarGravity()

Equivalence to convert between Sugar Contents and Specific Gravity quantities.

Convert between degrees Plato and specific gravity according to the equation

    Plato = 259 * (1 - 1/sg),

a simple approximation of the Plato tables, with the specific gravity at 60 °F.

# Examples

```jldoctest
julia> uconvert(u"°P", 1.040u"sg", SugarGravity())
9.961538461538483 °P
julia> uconvert(u"sg", 15u"°P", SugarGravity())
1.0614754098360655 sg
julia> uconvert(u"gu", 12u"°P", SugarGravity())
48.58299595141693 gu
julia> uconvert(u"°P", 40u"gu", SugarGravity())
9.961538461538483 °P
```

# References

- T. Foster, "Understanding Specific Gravity vs. Plato", *Brew Your Own*,
  <https://byo.com/?p=14253>, which gives it as one of the simpler of several proposed
  relations; its original source was not found.
"""
struct SugarGravity <: Equivalence end

edconvert(::dimtype(SugarContents), x::Unitful.DimensionlessQuantity,
    ::SugarGravity) = 259 * (1 - 1 / uconvert(sg, x).val) * °P

edconvert(::dimtype(Unitful.DimensionlessQuantity), x::SugarContents,
    ::SugarGravity) = 259 / (259 - uconvert(°P, x).val) * sg

"""
    SugarGravityQuad()

Equivalence to convert between Sugar Contents and Specific Gravity quantities.

Convert between degrees Plato and gravity units according to the quadratic
equation

    Plato = 0.25802gu - 0.00020535gu^2,

which is equivalent to the formula for specific gravity

    Plato = 668.72 * sg - 463.37 - 205.35 * sg^2,

with

    gu = 1000 ( sg - 1.000 ).

# Examples

```jldoctest
julia> uconvert(u"°P", 1.040u"sg", SugarGravityQuad())
9.992240000000002 °P
julia> uconvert(u"sg", 15u"°P", SugarGravityQuad())
1.0611068377146748 sg
julia> uconvert(u"gu", 12u"°P", SugarGravityQuad())
48.370088784473296 gu
julia> uconvert(u"°P", 40u"gu", SugarGravityQuad())
9.992240000000002 °P
```

# References

- "On the relationship between Plato and specific gravity", Brewer's Friend, 2012,
  <https://www.brewersfriend.com/2012/10/31/on-the-relationship-between-plato-and-specific-gravity>,
  which attributes this quadratic fit to Robbins (1975); the original publication was not
  found.
"""
struct SugarGravityQuad <: Equivalence end

edconvert(::dimtype(SugarContents), x::Unitful.DimensionlessQuantity,
    ::SugarGravityQuad) = gu_to_plato(uconvert(gu, x).val) * °P

edconvert(::dimtype(Unitful.DimensionlessQuantity), x::SugarContents,
    ::SugarGravityQuad) = plato_to_gu(uconvert(°P, x).val) * gu

# Register the above units and dimensions in Unitful
const localpromotion = copy(Unitful.promotion) # only needed with new dimensions
function __init__()
    Unitful.register(UnitfulBrewing) # needed for new Units
    merge!(Unitful.promotion, localpromotion) # only needed with new dimensions
end


end # module