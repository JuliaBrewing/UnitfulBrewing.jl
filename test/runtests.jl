using Unitful
using UnitfulBrewing
using Test

@testset "Dimensions and quantities" begin
    # new dimensions
    @test UnitfulBrewing.𝐂𝐋*UnitfulBrewing.𝐂𝐋 === UnitfulBrewing.𝐂𝐋^2 # Color
    @test UnitfulBrewing.𝐃𝐏*UnitfulBrewing.𝐃𝐏 === UnitfulBrewing.𝐃𝐏^2 # Diastatic Power
    @test UnitfulBrewing.𝐁𝐓*UnitfulBrewing.𝐁𝐓 === UnitfulBrewing.𝐁𝐓^2 # Bitterness
    @test UnitfulBrewing.𝐒𝐂*UnitfulBrewing.𝐒𝐂 === UnitfulBrewing.𝐒𝐂^2 # SugarContents

    # US Volumes not in Unitful
    @test @macroexpand(u"tsp") == u"tsp"
    @test @macroexpand(u"bbl") == u"bbl"
    @test uconvert(u"bbl", 31u"gal") == 1u"bbl" # US beer barrel
    @test uconvert(u"l", 1u"bbl") ≈ 117.347765304u"l"
    @test uconvert(u"gal", 16u"cup") == 1u"gal"
    @test uconvert(u"gal", 768u"tsp") == 1u"gal"

    # Imperial Volumes
    @test @macroexpand(u"ibbl") == u"ibbl"
    @test uconvert(u"ibbl", 36u"igal") == 1u"ibbl"
    @test uconvert(u"igal", 160u"ifloz") == 1u"igal"
    @test uconvert(u"ipt", 4u"gi") == 1u"ipt"
    @test dimension(u"igal") == dimension(u"l")
    @test uconvert(u"ml", 1u"ifloz") ≈ 28.4130625u"ml"
    @test uconvert(u"l", 1u"igal") ≈ 4.54609u"l"
    @test uconvert(u"l", 1u"gal") ≈ 3.785411784u"l"

    # concentrations (from Unitful)
    @test uconvert(NoUnits, 1u"ppm") == 1//10^6
    @test uconvert(NoUnits, 1u"ppb") == 1//10^9
    @test uconvert(NoUnits, 1u"ppt") == 1//10^12

    # sugar content and gravity
    @test @macroexpand(u"°P") == u"°P"
    @test u"P" === Unitful.P # poise, not degrees Plato
    @test @macroexpand(u"sg") == u"sg"
    @test @macroexpand(u"gu") == u"gu"

    # diastatic power
    @test @macroexpand(u"°Lintner") == u"°Lintner"
    @test @macroexpand(u"°WK") == u"°WK"
    @test uconvert(u"°Lintner", 19u"°WK") == 10u"°Lintner"

    # color
    @test @macroexpand(u"SRM") == u"SRM"
    @test @macroexpand(u"°L") == u"°L"
    @test @macroexpand(u"EBC") == u"EBC"
    @test @macroexpand(u"Lovi") == u"°L"
    @test uconvert(u"srm", 20u"ebc") == (2000//197)u"SRM"
    @test uconvert(u"EBC", 10u"SRM") == (197//10)u"EBC"
    @test uconvert(u"°L", 0u"SRM") == (7600//13546)u"°L"
    @test uconvert(u"°L", 20u"SRM") == (207600//13546)u"°L"

    # carbonation
    @test UnitfulBrewing.𝐂𝐁*UnitfulBrewing.𝐂𝐁 === UnitfulBrewing.𝐂𝐁^2
    @test @macroexpand(u"vols") == u"vols"
    @test dimension(u"vols") == UnitfulBrewing.𝐂𝐁
    @test_throws Unitful.DimensionError uconvert(NoUnits, 1u"vols")

    # pH
    @test [1,2,3]u"pwrH" == u"pH⁺" * [1,2,3]
    @test 3u"pH⁺" < 5u"pwrH"

    # time
    @test uconvert(u"week", 7u"day") == 1u"wk"
    @test uconvert(u"min", 60u"sec") == 1u"min"

    # Throw errors
    @test_throws Meta.ParseError macroexpand(@__MODULE__, :(u"ton Lovi"))
    @test_throws ArgumentError macroexpand(@__MODULE__, :(u"lovibond"))
end

@testset "Equivalences" begin
    # density and concentration
    @test uconvert(u"mg/l", 1u"ppm", DensityConcentration()) === 1u"mg/l"
    @test uconvert(u"kg/l", 10u"percent", DensityConcentration()) === (1//10)u"kg/l"
    @test uconvert(u"ppm", 1u"mg/l", DensityConcentration()) === 1.0u"ppm"

    # sugar contents and gravity with SugarGravity
    @test uconvert(u"sg", 10u"°P", SugarGravity()) ≈ 1.0401606425u"sg"
    @test uconvert(u"gu", 10u"°P", SugarGravity()) ≈ 40.160642u"gu"
    @test uconvert(u"°P", 1.040u"sg", SugarGravity()) ≈ 9.9615384615u"°P"
    @test uconvert(u"°P", 40u"gu", SugarGravity()) ≈ 9.9615384615u"°P"

    # sugar contents and gravity with SugarGravityQuad
    @test uconvert(u"sg", 10u"°P", SugarGravityQuad()) ≈ 1.040032121u"sg"
    @test uconvert(u"gu", 10u"°P", SugarGravityQuad()) ≈ 40.03u"gu" (atol = 0.01u"gu")
    @test uconvert(u"°P", 1.040u"sg", SugarGravityQuad()) ≈ 9.99224u"°P"
    @test uconvert(u"°P", 40u"gu", SugarGravityQuad()) ≈ 9.99u"°P" (atol = 0.01u"°P")

    # carbonation and density of CO₂
    @test uconvert(u"g/l", 1u"vols", CarbonationDensity()) ≈ 1.977u"g/l"
    @test uconvert(u"g/l", 2.5u"vols", CarbonationDensity()) ≈ 4.9425u"g/l"
    @test uconvert(u"vols", 1.977u"g/l", CarbonationDensity()) ≈ 1u"vols"
    @test uconvert(u"vols", 4.9425u"kg/m^3", CarbonationDensity()) ≈ 2.5u"vols"
end
