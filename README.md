# UnitfulBrew

A supplemental units package for [Unitful.jl](https://github.com/PainterQubits/Unitful.jl.git), with units used in the beer brewing process.

## Team

(add people in the development team)

## Defined dimensions and units

List here the dimensions and units defined in this package...

- Dimensions:
  - 𝐂 for Color
  - 𝐃 for Diastatic Power
  - 𝐁 for Bitterness

- Units:
(add units...)

## Equivalences

Although degrees Plato and specific gravity measure different things, they are both used for estimating the amount of fermentables in the wort. Moreover, it is common to treat them interchangeably, according to a suitable quadratic relation between them. In order to account for that, we use here the package [`UnitfulEquivalences.jl`](https://github.com/sostock/UnitfulEquivalences.jl) (under development), which is inspired by the equivalences in [astropy.units: equivalencies](https://docs.astropy.org/en/stable/units/equivalencies.html).

Moreover, as it is commonly done in he brewing community, `ppm` and `mg/l` are also considered equivalent.

## Usage examples

Add examples...

```julia
julia> using Unitful
julia> using UnitfulEquivalences
julia> using UnitfulBrew

julia> uconvert(u"°P", 1.040u"sg", Brewing())
9.992240000000066 °P

julia> uconvert(u"sg", 15u"°P", Brewing())
1.0611068377146742 sg
```

## License

MIT license ...
