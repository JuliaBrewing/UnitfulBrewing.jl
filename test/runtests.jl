using Unitful
using UnitfulBrew
using Test

@testset "Brew quantities" begin
    # new dimensions
    @test UnitfulBrew.𝐂*UnitfulBrew.𝐂 === UnitfulBrew.𝐂^2 # Color
    @test UnitfulBrew.𝐃*UnitfulBrew.𝐃 === UnitfulBrew.𝐃^2 # Diastatic Power
    @test UnitfulBrew.𝐁*UnitfulBrew.𝐁 === UnitfulBrew.𝐁^2 # Bitterness

    # US Volumes not in Unitful
    @test @macroexpand(u"tsp") == u"tsp"
    @test @macroexpand(u"bbl") == u"bbl"
    @test uconvert(u"bbl", 42u"gal") == 1u"bbl"
    @test uconvert(u"gal", 16u"cup") == 1u"gal"
    @test uconvert(u"gal", 768u"tsp") == 1u"gal"

    # Imperial Volumes
    @test @macroexpand(u"ibbl") == u"ibbl"
    @test uconvert(u"ibbl", 36u"igal") == 1u"ibbl"
    @test uconvert(u"igal", 160u"ifloz") == 1u"igal"
    @test uconvert(u"ipt", 4u"gi") == 1u"ipt"

    # sugar content and gravity
    @test @macroexpand(u"°P") == u"°P"
    @test @macroexpand(u"sg") == u"sg"

    # diastatic power
    @test @macroexpand(u"°Lintner") == u"°Lintner"
    @test @macroexpand(u"°WK") == u"°WK"
    @test uconvert(u"°Lintner", 19u"°WK") == 10u"°Lintner"
    @test uconvert(u"Lintner", 19u"WK") == 10u"°Lintner"

    # color
    @test @macroexpand(u"SRM") == u"SRM"
    @test @macroexpand(u"°L") == u"°L"
    @test @macroexpand(u"EBC") == u"EBC"
    @test @macroexpand(u"Lovi") == u"°L"
    @test uconvert(u"srm", 20u"ebc") == (197//5)u"SRM"

    # pH
    @test [1,2,3]u"pwrH" == u"pH⁺" * [1,2,3]
    @test 3u"pH⁺" < 5u"pwrH"

    # time
    @test uconvert(u"week", 7u"day") == 1u"wk"
    @test uconvert(u"min", 60u"sec") == 1u"min"

    # equivalencies
    @test round(econvert(u"sg", 0u"°P")) == 1u"sg"
    @test round(1000*econvert(u"sg", 10u"°P")) == 1040u"sg"
    @test round(econvert(u"°P", 1u"sg")) == 0u"°P"
    @test round(econvert(u"°P", 1.040u"sg")) == 10u"°P"

    # Throw errors
    @test_throws LoadError @macroexpand(u"ton Lovi")
    @test_throws LoadError @macroexpand(u"Lovibond")
end
