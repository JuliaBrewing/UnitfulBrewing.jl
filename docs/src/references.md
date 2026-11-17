# References

The sources of the definitions of the units and of the relations used in the equivalences.
Where no original source was found, this is said explicitly.

## Volumes

- **US units** (`gal` = 231 in³, `qt`, `pt`, `floz`, `cup`, `tbsp`, `tsp`): NIST
  Handbook 44, Appendix C, "General Tables of Units of Measurement",
  <https://www.nist.gov/document/appc-19-hb44-finaldocx>.
- **US beer barrel** (`bbl` = 31 gal): 27 CFR § 25.11, "Meaning of terms" (Alcohol and
  Tobacco Tax and Trade Bureau), <https://www.law.cornell.edu/cfr/text/27/25.11>; see also
  the TTB beer FAQ, <https://www.ttb.gov/beer/beer-faqs>.
- **Imperial units** (`igal` = 4.54609 L, `iqt`, `ipt`, `gi`, `ifloz`): UK Weights and
  Measures Act 1985, Schedule 1, <https://www.legislation.gov.uk/ukpga/1985/72/schedule/1>.
  The imperial beer barrel (`ibbl`) of 36 imperial gallons is the traditional British one.

## Sugar contents and gravity

- **Degrees Plato, Brix and Balling** are mass percentages of sucrose (or extract) in
  solution, from the tables of Balling (1843), Brix (1854) and Plato (early 20th century).
  The tables differ slightly; they are taken as equal here.
- **Gravity units** (`gu` = 1000 (sg − 1)) and gravity points are the usual brewing
  conventions.
- **[`SugarGravity`](@ref)**, `°P = 259 (1 − 1/sg)`: given by T. Foster, "Understanding
  Specific Gravity vs. Plato", *Brew Your Own*, <https://byo.com/?p=14253>, as one of the
  simpler of several proposed relations. No original source was found.
- **[`SugarGravityQuad`](@ref)**, `°P = 668.72 sg − 463.37 − 205.35 sg²`: attributed to
  Robbins (1975) in "On the relationship between Plato and specific gravity", Brewer's
  Friend, 2012,
  <https://www.brewersfriend.com/2012/10/31/on-the-relationship-between-plato-and-specific-gravity>.
  The original publication was not found.

## Color

- **SRM and EBC**: both are proportional to the absorbance at 430 nm, `A430`, in a 1 cm
  cell. `SRM = 12.7 A430` (ASBC Methods of Analysis, Beer-10, adopted in 1950) and
  `EBC = 25 A430` (EBC Analytica), hence `EBC = (25/12.7) SRM ≈ 1.97 SRM`. See e.g. the
  Thermo Fisher application note "Beer analysis",
  <https://assets.thermofisher.com/TFS-Assets/MSD/Application-Notes/SN53076-analyze-beer-color-uv-vis.pdf>,
  and the ASBC's own pages on color.
- **Lovibond**, `SRM = 1.3546 °L − 0.76`: an empirical fit to the EBC and Lovibond values
  published by maltsters, as described in the Wikipedia article "Standard Reference Method",
  <https://en.wikipedia.org/wiki/Standard_Reference_Method>. Its original source was not
  found. The fit is good for pale colors and worsens for dark ones.

## Diastatic power

- **Windisch–Kolbach**, `°WK = 3.5 °Lintner − 16`: the usual approximate interconversion
  between the ASBC (°Lintner) and EBC (°WK) methods. It is given, e.g., in G. Oliver (ed.),
  *The Oxford Companion to Beer*, Oxford University Press, 2011, and in the Megazyme data
  sheet E-MASTP,
  <https://prod-docs.megazyme.com/documents/Data_Sheet/E-MASTP_DATA.pdf>.

## Carbonation

- **`vols`**: volumes of CO₂, at 0 °C and 1 atm, per volume of beer, as in the BeerJSON
  schema, <https://github.com/beerjson/beerjson>.
- **[`CarbonationDensity`](@ref)**: uses the density of gaseous CO₂ at 0 °C and 1 atm,
  1.977 kg/m³ (CRC Handbook of Chemistry and Physics), which follows from its molar mass of
  44.009 g/mol.

## Concentrations

- **[`DensityConcentration`](@ref)**, 1 ppm ≈ 1 mg/L: this assumes a density of 1 kg/L
  for the solution. It is the usual convention for dilute aqueous solutions, as in
  brewing water chemistry.
