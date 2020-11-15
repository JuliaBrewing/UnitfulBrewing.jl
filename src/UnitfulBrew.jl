__precompile__(true)
"""
    UnitfulBrew

Module extending Unitful.jl with beer brewing units.
"""
module UnitfulBrew

using Unitful

using UnitfulEquivalences: Equivalence, dimtype, @eqrelation
import UnitfulEquivalences: edconvert

export DensityConcentration, SugarGravity, SugarGravity2

# New dimensions
@dimension 𝐂    "C"     Color
@dimension 𝐃    "𝐃"     DiastaticPower
@dimension 𝐁    "𝐁"     Bitterness
@dimension 𝐒    "S"     SugarContents

# Time units: adding beerjson symbols as alias to Unitful symbols
const sec = Unitful.s
const min = Unitful.minute
const day = Unitful.d
const week = Unitful.wk

# US Volumes
@unit gal       "gal"       Gallon      231*(Unitful.inch)^3    false
@unit qt        "qt"        Quart       gal//4                  false
@unit pt        "pt"        Pint        qt//2                   false
@unit cup       "cup"       Cup         pt//2                   false
@unit floz      "floz"      FluidOunce  pt//16                  false
@unit tbsp      "tbsp"      Tablespoon  floz//2                 false
@unit tsp       "tsp"       Teaspoon    tbsp//3                 false
@unit bbl       "bbl"       Barrel      42gal                   false

# Imperial Volumes
@unit ifloz     "ifloz"     ImperialFluidOunce  28.4130625*(Unitful.mm) false
@unit gi        "gi"        Gill                5ifloz                  false
@unit ipt       "ipt"       ImperialPint        20ifloz                 false
@unit iqt       "iqt"       ImperialQuart       2ipt                    false
@unit igal      "igal"      ImperialGallon      8ipt                    false
@unit ibbl      "ibbl"      ImperialBarrel      36igal                  false

# Sugar content
@refunit °P     "°P"        Plato               𝐒           false
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
@refunit        °Lintner    "°Lintner"  Lintner     𝐃                   false
@unit           °WK_aux     "°WK_aux"   WK_aux      (10//35)°Lintner    false
@affineunit     °WK         "°WK"       16°WK_aux
const Lintner = °Lintner
const WK = °WK

# Color units
@refunit    SRM     "SRM"       SRM                 𝐂                   false      
@unit       EBC     "EBC"       EBC                 (100//197)SRM       false
@unit       L_aux   "L_aux"     L_aux               (13546//10000)SRM    false
@affineunit °L      "°L"        -(7600//13546)L_aux
const srm = SRM
const Lovi = °L
const Lovibond = °L
const ebc = EBC

# Carbonation units

# International Bitterness Unit

@refunit    IBU     "IBU"       InternationalBitternessUnit 𝐁       false

# Concentration units
#=
Unitful already has percent, permille and pertenthousand,
so we only add ppm, ppb, and ppt
@unit percent         "%"    Percent         1//100             false
@unit permille        "‰"    Permille        1//1000            false
@unit pertenthousand  "‱"    Pertenthousand  1//10000           false
=#
@unit       ppm     "ppm"       PartsPerMillion     1//10^6         false
@unit       ppb     "ppb"       PartsPerBillion     1//10^9         false
@unit       ppt     "ppt"       PartsPerTrillion    1//10^9         false

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
9.992240000000002 °P
julia> uconvert(u"sg", 15u"°P", SugarGravity())
1.0611068377146748 sg
julia> uconvert(u"gu", 12u"°P", SugarGravity())
48.370088784473296 gu
julia> uconvert(u"°P", 40u"gu", SugarGravity())
9.992240000000002 °P
```
"""
struct SugarGravity <: Equivalence end

edconvert(::dimtype(SugarContents), x::Unitful.DimensionlessQuantity,
    ::SugarGravity) = 259 * (1 - 1 / uconvert(sg, x).val) * °P

edconvert(::dimtype(Unitful.DimensionlessQuantity), x::SugarContents,
    ::SugarGravity) = 259 / (259 - uconvert(°P, x).val) * sg

"""
    SugarGravity2()

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
julia> uconvert(u"°P", 1.040u"sg", SugarGravity2())
9.992240000000002 °P
julia> uconvert(u"sg", 15u"°P", SugarGravity2())
1.0611068377146748 sg
julia> uconvert(u"gu", 12u"°P", SugarGravity2())
48.370088784473296 gu
julia> uconvert(u"°P", 40u"gu", SugarGravity2())
9.992240000000002 °P
```
"""
struct SugarGravity2 <: Equivalence end

edconvert(::dimtype(SugarContents), x::Unitful.DimensionlessQuantity,
    ::SugarGravity2) = gu_to_plato(uconvert(gu, x).val) * °P

edconvert(::dimtype(Unitful.DimensionlessQuantity), x::SugarContents,
    ::SugarGravity2) = plato_to_gu(uconvert(°P, x).val) * gu

# The function below is just so I get things straight
function show_quantity_info(x::Quantity{T,D,U}) where {T,D,U}
    println("Here is the result of (T, D, U, U()) for $x:")
    return T, D, U, U()
end

# Register the above units and dimensions in Unitful
__init__() = Unitful.register(UnitfulBrew)

end # module