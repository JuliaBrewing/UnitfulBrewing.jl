"""
    UnitfulBrewing

Module extending Unitful.jl with beer brewing units.
"""
module UnitfulBrewing

using Unitful

using UnitfulEquivalences: Equivalence, dimtype, @eqrelation
import UnitfulEquivalences: edconvert

export DensityConcentration, SugarGravity, SugarGravityQuad

# New dimensions
@dimension 𝐂𝐋   "𝐂𝐋"     Color
@dimension 𝐃𝐏   "𝐃𝐏"     DiastaticPower
@dimension 𝐁𝐓   "𝐁𝐓"     Bitterness
@dimension 𝐒𝐂   "𝐒𝐂"     SugarContents

# Time units: adding beerjson symbols as alias to Unitful symbols
const sec = Unitful.s
const min = Unitful.minute
const day = Unitful.d
const week = Unitful.wk

# US volumes
@unit gal       "gal"       Gallon      231*(Unitful.inch)^3    false
@unit qt        "qt"        Quart       gal//4                  false
@unit pt        "pt"        Pint        qt//2                   false
@unit floz      "floz"      FluidOunce  pt//16                  false
@unit bbl       "bbl"       Barrel      42gal                   false

# Imperial volumes
@unit ifloz     "ifloz"     ImperialFluidOunce  28.4130625*(Unitful.mL)  false
@unit gi        "gi"        Gill                5ifloz                  false
@unit ipt       "ipt"       ImperialPint        20ifloz                 false
@unit iqt       "iqt"       ImperialQuart       2ipt                    false
@unit igal      "igal"      ImperialGallon      8ipt                    false
@unit ibbl      "ibbl"      ImperialBarrel      36igal                  false

# Culinary volumes
@unit cup       "cup"       Cup         pt//2                   false
@unit tbsp      "tbsp"      Tablespoon  cup//16                 false
@unit tsp       "tsp"       Teaspoon    tbsp//3                 false


# Sugar content
@refunit °P     "°P"        Plato               𝐒𝐂          false
@unit Brix      "Brix"      Brix                1°P         false
@unit Balling   "Balling"   Balling             1°P         false
const P = °P

# Specific gravity
# uconvert(Unitful.NoUnits, 1.010u"sg") == 1.01
# uconvert(u"permille", 1.040u"sg") == 1040.0 ‰
# uconvert(u"gu", 1.040u"sg") == 40.0 gu
# uconvert(u"sg", 40u"gu") == 1.04 sg
@unit       sg  "sg"        SpecificGravity     1.0         false
@affineunit gu  "gu"        1000.0 * Unitful.permille
const gp = gu # gravity points

# Diastatic Power
@refunit        °Lintner    "°Lintner"  Lintner     𝐃𝐏                  false
@unit           °WK_aux     "°WK_aux"   WK_aux      (10//35)°Lintner    false
@affineunit     °WK         "°WK"       16°WK_aux
const Lintner = °Lintner
const WK = °WK

# Color units
@refunit    SRM     "SRM"       SRM                 𝐂𝐋                  false      
@unit       EBC     "EBC"       EBC                 (100//197)SRM       false
@unit       L_aux   "L_aux"     L_aux               (13546//10000)SRM    false
@affineunit °L      "°L"        -(7600//13546)L_aux
const srm = SRM
const Lovi = °L
const Lovibond = °L
const ebc = EBC

# Carbonation units

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

Convert a value in Gravity Units to degrees Plato according
to the quadratic formula

    Plato = 0.25802gu - 0.00020535gu^2,

which is equivalent to the formula for specific gravity

    Plato = 668.72 * sg - 463.37 - 205.35 * sg^2,

with
    gu = 1000 ( sg - 1.000 ).
"""
gu_to_plato(gu::Number) = 0.25802gu - 0.00020535gu^2

"""
    plato_to_gu(p::Number)

Convert a value in degrees Plato to Gravity Units by inverting the quadratic
formula for degrees Plato, so that

    gu = e - sqrt(e^2 - g * Plato)) if ^2 - g * p >= 0 else gu = e

where 
    e = 0.25802 / 0.00020535 / 2 = 628.2444606768931
and 
    g = 1 / 0.00020535 = 4869.734599464329

The value gu = d when p > d/2 is just for definiteness of the function since
the in this range the conversion is meaningless.
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

# Examples

```jldoctest
julia> uconvert(u"mg/l", 10u"ppm", DensityConcentration())
10 mg L⁻¹
julia> uconvert(u"ppm", 1u"g/l", DensityConcentration())
1000 ppm
```
"""
struct DensityConcentration <: Equivalence end

@eqrelation DensityConcentration Unitful.Density / Unitful.DimensionlessQuantity = 1u"kg/l"

"""
    SugarGravity()

Equivalence to convert between Sugar Contents and Specific Gravity quantities.

Convert between degrees Plato and specific gravity according to the equation

    Plato = 259 * (1 - 1/sg),

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