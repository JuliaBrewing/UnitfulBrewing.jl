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

Although degrees Plato and specific gravity measure different things, they are both used for estimating the amount of fermentables in the wort. Moreover, it is common to treat them interchangeably, according to a suitable nonlinear function between both quantities. In order to account for that, we implement here the notion of `equivalency`, as done in [astropy.units: equivalencies](https://docs.astropy.org/en/stable/units/equivalencies.html).

(add more info on that and mention the example below)

## Usage examples

Add examples...

```julia
using Unitful
using UnitfulBrew

p = 10u"°P"
sg = econvert(u"sg", p)
```

## License

MIT license ...
