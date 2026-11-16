```@meta
DocTestSetup = :(using Unitful, UnitfulBrewing)
```

# Dimensions and units

## Dimensions

UnitfulBrewing adds the following dimensions to the ones in Unitful:

| Dimension | Quantity       | Reference unit |
|:--------- |:-------------- |:-------------- |
| `𝐒𝐂`      | Sugar contents | `°P`           |
| `𝐂𝐋`      | Color          | `SRM`          |
| `𝐁𝐓`      | Bitterness     | `IBU`          |
| `𝐃𝐏`      | Diastatic power | `°Lintner`    |
| `𝐂𝐁`      | Carbonation    | `vols`         |

Each one is a dimension of its own, so, for instance, a color cannot be accidentally added to a bitterness or converted to a plain number.

## Sugar contents and gravity

| Unit      | Name                | Definition |
|:--------- |:------------------- |:---------- |
| `°P`      | degree Plato        | reference unit for `𝐒𝐂` |
| `Brix`    | degree Brix         | currently equal to `°P` |
| `Balling` | degree Balling      | currently equal to `°P` |
| `sg`      | specific gravity    | dimensionless, `1 sg = 1` |
| `gu`      | gravity unit        | affine: `gu = 1000 (sg - 1)` |
| `gp`      | gravity point       | alias of `gu` |

A specific gravity of 1.040 is 40 gravity units:

```jldoctest
julia> uconvert(u"gu", 1.040u"sg")
40.0 gu

julia> uconvert(u"sg", 48u"gu")
1.048 sg
```

Sugar contents and specific gravity have different dimensions, so converting between them requires one of the equivalences [`SugarGravity`](@ref) or [`SugarGravityQuad`](@ref); see [Equivalences](equivalences.md).

## Color

| Unit  | Name                                  | Definition |
|:----- |:------------------------------------- |:---------- |
| `SRM` | Standard Reference Method             | reference unit for `𝐂𝐋` |
| `EBC` | European Brewery Convention           | `EBC = 1.97 SRM` |
| `°L`  | degree Lovibond                       | affine: `SRM = 1.3546 °L - 0.76` |

`srm`, `ebc`, `Lovi` and `Lovibond` are aliases of `SRM`, `EBC` and `°L`.

```jldoctest
julia> uconvert(u"EBC", 10u"SRM")
197//10 EBC

julia> round(u"°L", 20u"SRM", digits=2)
15.33 °L
```

## Bitterness

| Unit  | Name                          | Definition |
|:----- |:----------------------------- |:---------- |
| `IBU` | International Bitterness Unit | reference unit for `𝐁𝐓` |

## Diastatic power

| Unit       | Name                   | Definition |
|:---------- |:---------------------- |:---------- |
| `°Lintner` | degree Lintner         | reference unit for `𝐃𝐏` |
| `°WK`      | Windisch–Kolbach unit  | affine: `°WK = 3.5 °Lintner - 16` |

`Lintner` and `WK` are aliases of `°Lintner` and `°WK`.

```jldoctest
julia> uconvert(u"°Lintner", 19u"°WK")
10//1 °Lintner
```

## Carbonation

| Unit   | Name           | Definition |
|:------ |:-------------- |:---------- |
| `vols` | volumes of CO₂ | reference unit for `𝐂𝐁`: volumes of CO₂, at 0 °C and 1 atm, dissolved per volume of beer |

`vols` is the unit used for carbonation by [BeerJSON](https://github.com/beerjson/beerjson). Use the equivalence [`CarbonationDensity`](@ref) to convert to and from the mass of CO₂ per volume, in g/l.

## Concentration

Unitful (since v1.19) already defines `percent`, `permille`, `pertenthousand`, `pcm`, `ppm`, `ppb`, `ppt` and `ppq`, which are used here as they are. Use the equivalence [`DensityConcentration`](@ref) to convert between these and mass per volume, such as mg/l.

## pH

| Unit  | Name              | Definition |
|:----- |:----------------- |:---------- |
| `pH⁺` | power of hydrogen | logarithmic unit, base 10 |
| `pwrH`| power of hydrogen | alias of `pH⁺` |

The usual symbol `pH` cannot be used, since Unitful already defines `pH` as the picohenry, a unit of electrical inductance.

```jldoctest
julia> 3u"pH⁺" < 5u"pwrH"
true
```

## Time

These are aliases for Unitful's time units, under the names used by BeerJSON:

| Alias  | Unitful unit |
|:------ |:------------ |
| `sec`  | `s`          |
| `min`  | `minute`     |
| `day`  | `d`          |
| `week` | `wk`         |

```jldoctest
julia> uconvert(u"min", 1u"hr")
60 minute
```

## Volumes

### US volumes

| Unit   | Name           | Definition |
|:------ |:-------------- |:---------- |
| `gal`  | US gallon      | 231 in³ (≈ 3.785 L) |
| `qt`   | US quart       | `gal/4` |
| `pt`   | US pint        | `qt/2` |
| `floz` | US fluid ounce | `pt/16` |
| `bbl`  | US beer barrel | `31 gal` (≈ 117.35 L) |

Note that `bbl` is the US *beer* barrel, of 31 US gallons, and not the 42-gallon oil barrel.

### Imperial volumes

| Unit    | Name                  | Definition |
|:------- |:--------------------- |:---------- |
| `ifloz` | imperial fluid ounce  | 28.4130625 mL |
| `gi`    | gill                  | `5 ifloz` |
| `ipt`   | imperial pint         | `20 ifloz` |
| `iqt`   | imperial quart        | `2 ipt` |
| `igal`  | imperial gallon       | `8 ipt` (= 4.54609 L) |
| `ibbl`  | imperial beer barrel  | `36 igal` |

### Culinary volumes

| Unit   | Name       | Definition |
|:------ |:---------- |:---------- |
| `cup`  | cup        | `pt/2` |
| `tbsp` | tablespoon | `cup/16` |
| `tsp`  | teaspoon   | `tbsp/3` |

```jldoctest
julia> round(u"l", 1u"bbl", digits=2)
117.35 L

julia> uconvert(u"ipt", 1u"igal")
8 ipt

julia> round(u"l", 1u"igal", digits=5)
4.54609 L

julia> uconvert(u"floz", 1u"cup")
8.0 floz
```
