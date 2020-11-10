__precompile__(true)
"""
    UnitfulBrew

Module extending Unitful.jl with beer brewing units.
"""
module UnitfulBrew

using Unitful
#using UnitfulEquivalences
using UnitfulEquivalences: dimtype, @equivalence
import UnitfulEquivalences: edconvert

export Brewing

# New dimensions
@dimension 𝐂    "C"     Color
@dimension 𝐃    "𝐃"     DiastaticPower
@dimension 𝐁    "𝐁"     Bitterness

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

# Sugar content and gravity (maybe sg should be an affine quantity)
@unit °P        "°P"        Plato               1               true
@unit sg        "sg"        SpecificGravity     1               true
@unit Brix      "Brix"      Brix                1               true
@unit gu        "gu"        GravityUnit         1               true
const gp = gu # gravity points

# Diastatic Power
@refunit        °Lintner    "°Lintner"  Lintner     𝐃                   false
@unit           °WKabs      "°WKabs"    WKabs       (10//35)°Lintner    false
@affineunit     °WK         "°WK"       16°WKabs
const Lintner = °Lintner
const WK = °WK

# Color units
@refunit    SRM     "SRM"       SRM                 𝐂               false
@unit       °L      "°L"        Lovibond            1SRM            false
@unit       EBC     "EBC"       EBC                 (197//100)SRM   false
const srm = SRM
const Lovi = °L
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
Using symbols pwrH and pH⁺ since there is a dimensional symbol pH already defined in Unitful:
```julia-repl
julia> typeof(Unitful.pH)
Unitful.FreeUnits{(pH,),𝐋² 𝐌 𝐈⁻² 𝐓⁻²,nothing}
```
=#

## Define the conversion functions between Plato and specific gravity

"""
    function plato_to_sg(x)

Convert from degrees `Plato` to specific gravity `sg` using the 
quadratic equation

    205.35 * sg^2 - 668.72 * sg +  463.37 + Plato = 0.

This formula is considered to be a good approximation for reasonable
values of degrees Plato. It can be solved for sg when Plato is below
approximately 81 degrees, with sg being given by the smallest root 
of the equation. When Plato is above this value, the function returns
668.72/410.70, just for definiteness since it is way outside the validity
range.
"""
function plato_to_sg(x::Quantity{T,D,U}) where {T,D,U}
    if U() == UnitfulBrew.°P
        a = 205.35; b = -668.72; c = 463.37
        mp = - b/2/a # maximal point of the parabola P = P(sg)
        mpsq = mp^2
        mv = mpsq * a - c # maximal value of the parabola P = P(sg)
        p = x.val
        if p < mv
#            sg = (- b - sqrt(b^2 - 4 * a * (c + p)) )/2/a
            sg = mp - sqrt(mpsq - (c + p)/a)
            return sg * UnitfulBrew.sg
        else
#            return -b/2/a * UnitfulBrew.sg
            return mp * UnitfulBrew.sg
        end
    else
        throw(error("Argument of plato_to_sg() must be a quantity in degrees Plato"))
    end
end

"""
    function sg_to_plato(x)

Convert from specific gravity `sg` to degrees `Plato` using the formula

    Plato = 668.72 * sg - 463.37 - 205.35 * sg^2.

This formula is considered a good approximation for reasonable values
of the specific gravity.
"""
function sg_to_plato(x::Quantity{T,D,U}) where {T,D,U}
    if U() == UnitfulBrew.sg
        sg = x.val
        p = 668.72 * sg - 463.37 - 205.35 * sg^2
        return p * UnitfulBrew.°P
    else
        throw(error("Argument of sg_to_plato() must be a specific gravity quantity"))
    end
end

# Define the equivalences

_eqconversion_error(v, u, e) = error("$e does not define conversion from $u to $v")

"""
    Brewing()

Equivalence to convert brewing related quantities.

* Convert between Density and NoDims according to a linear relation with 1u"mg/L" equivalent to 1u"ppm"

* Convert between degrees Plato and specific gravity (need to include gravity points, as well)

# Examples

```jldoctest
julia> uconvert(u"mg/l", 10u"ppm", Brewing())
10 mg L⁻¹
julia> uconvert(u"ppm", 1u"g/l", Brewing())
1000 ppm
julia> uconvert(u"°P", 1.040u"sg", Brewing())
9.992240000000066 °P
julia> uconvert(u"sg", 15u"°P", Brewing())
1.0611068377146742 sg
```
"""
@equivalence Brewing

edconvert(d::dimtype(Unitful.Density), x::Unitful.Quantity{T,D,U}, e::Brewing) where {T,D,U} = D == Unitful.NoDims ? x * 1u"kg/L" : throw(_eqconversion_error(d, D, e))

function edconvert(d::Unitful.Dimensions{()}, x::Unitful.Quantity{T,D,U}, e::Brewing) where {T,D,U} 
    if U() == UnitfulBrew.sg
        sg_to_plato(x)
    elseif U() == UnitfulBrew.°P
        plato_to_sg(x)
    elseif D == Unitful.𝐌/Unitful.𝐋^3
        x * 1u"L/kg" # Density to parts per (e.g. 1u"ppm" = 1u"mg/l")
    else
        throw(_eqconversion_error(d, Unitful.unit(x), e))
    end
end

# The function below is just so I get things straight
function show_quantity_info(x::Quantity{T,D,U}) where {T,D,U}
    println("Here is the result of (T, D, U, U()) for $x:")
    return T, D, U, U()
end

# Register the above units and dimensions in Unitful
__init__() = Unitful.register(UnitfulBrew)

end # module