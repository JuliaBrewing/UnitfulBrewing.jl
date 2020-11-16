# UnitfulBrewing

A supplemental units package for [Unitful.jl](https://github.com/PainterQubits/Unitful.jl), with units used in the beer brewing process.

## Defined dimensions and units

We add the following dimensions and units in this package:

- Dimensions:
  - 𝐂 for Color
  - 𝐃 for Diastatic Power
  - 𝐁 for Bitterness
  - 𝐒 for Sugar Contents

- Units:
  - Sugar contents:
    - `°P` standing for degrees Plato, as the reference unit for dimension 𝐒
    - `Brix`, which currently is equal to `°P`
    - `Balling`, which currently is equal to `°P`
  - Specific gravity:
    - `sg`, standing for specific gravity, a nondimensional quantity.
    - `gu`, standing for gravity unit, an affine unit related to `sg` by `gu = 1000 (sg - 1)`, i.e. a specific gravity of 1.040 equals 40 gravity units.
    - `gp` is *gravity point*, which equals `gu`.
  - Bitterness:
    - `IBU`, for *International Bitterness Unit*, as the reference unit for dimension 𝐁
  - Color units:
    - `SRM` is the *Standard Reference Method*, which is taken as the reference unit for beer color.
    - `EBC`, for *European Brewery Convention*, which is related to `SRM` by `EBC = 1.97 SRM`.
    - `°L`, standing for *degree Lovibond*, an affine unit related to `SRM` by `SRM = 1.3546 °L - 0.76`.
  - Diastatic power:
    - `°Lintner`, standing for degrees Lintner, as the reference unit for diastatic power.
    - `°WK`, standing for Windisch–Kolbach units, an affine unit which is related to degrees Lintner by `°Lintner` by `°WK = (3.5 * °Lintner) - 16`.
  - Concentration units:
    - `ppm` is *parts per million*
    - `ppb` is *parts per billion*
    - `ppt` is *parts per trillion*
    - Other quantities such as `percent`, `permille`, and `pertenthousand` are already defined in [Unitful.jl](https://github.com/PainterQubits/Unitful.jl)
  - Carbonation:
    - **It remains to be implemented**
  - pH:
    - `pH⁺` is a logarithmic unit standing for the *power of hydrogen*.
    - `pwrH` serves as an alias for `pH⁺`
    - The classic symbol `pH` is already taken in [Unitful.jl](https://github.com/PainterQubits/Unitful.jl), with `Unitful.pH` representing picoHenry, where Henry (H) is the SI unit of electrical inductance, with dimension 𝐋² 𝐌 𝐈⁻² 𝐓⁻²
  - Time units (just aliases relating the notation used in the [BeerJSON format standard](https://github.com/beerjson/beerjson) (under development) to those defined in [Unitful.jl](https://github.com/PainterQubits/Unitful.jl)):
    - `sec` equals `Unitful.s`
    - `min` equals `Unitful.minute`
    - `day` equals `Unitful.d`
    - `week` equals `Unitful.wk`
  - US volumes
    - **Add description**
  - Imperial volumes
    - **Add description**

## Equivalences

Although degrees Plato and specific gravity measure different things, they are both used for estimating the amount of fermentables in the wort. In fact, it is common to treat them interchangeably, according to suitable nonlinear relations between them. In order to account for that, we use here the package [`UnitfulEquivalences.jl`](https://github.com/sostock/UnitfulEquivalences.jl) (under development), which is inspired by [astropy.units: equivalencies](https://docs.astropy.org/en/stable/units/equivalencies.html). We implement two equivalences, one according to a rational equation and another according to a quadratic equation.

Similarly, as it is commonly done in he brewing community (and in other fields considering small quantities of solutes dissolved in water), `ppm` and `mg/l` are also treated interchangeably.

### Sugar contents and gravity equivalence

Using the [`UnitfulEquivalences.jl`](https://github.com/sostock/UnitfulEquivalences.jl) package, we define two *equivalence types*, `SugarGravity` and `SugarGravityQuad`, to relate degrees Plato to specific gravity and gravity units.

The equivalence `SugarGravity` relates a quantity `plato` in degrees Plato to a quantity `sg` in specific gravity according to

$$ \text{plato} = 259 \left(1 - \frac{1}{\text{sg}}\right)
$$

The equivalence `SugarGravityQuad` relates such quantities according to the quadratic equation

$$ \text{plato} = 668.72 \,\text{sg} - 463.37 - 205.35 \,\text{sg}^2
$$

With these equivalence types, the conversions between the above quantities are done as in the folowing examples:

```julia
julia> using Unitful
julia> using UnitfulBrewing

julia> uconvert(u"°P", 1.040u"sg", SugarGravity())
9.961538461538483 °P

julia> uconvert(u"sg", 10u"°P", SugarGravity())
1.0401606425702812 sg

julia> uconvert(u"gu", 10u"°P", SugarGravityQuad())
40.032121145872225 gu
```

The relative difference between these two equivalences, in the range of interest, say from 0°P up to 30°P, is of less than 0.4%.

### Density and concentration equivalence

For the equivalence between density and concentration, we define the *equivalence type* `DensityConcentration`, so that, for example

```julia
julia> uconvert(u"mg/l", 10u"ppm", DensityConcentration())
10 mg L⁻¹
julia> uconvert(u"ppm", 1u"g/l", DensityConcentration())
1000 ppm
```

## License

This package is licensed under the [MIT license](https://opensource.org/licenses/MIT). See the file [LICENSE](LICENSE) in the root directory of the project.
