## Error handling
"""
    struct EquivalenceConversionQuantitiesError <: Exception

No equivalence conversion available between the two given physical dimensions.
"""
struct EquivalenceConversionQuantitiesError <: Exception
    x
    y
end

"""
    struct EquivalenceConversionFunctionError <: Exception

Equivalence conversion does not apply to the given physical dimensions
"""
struct EquivalenceConversionFunctionError <: Exception
    x
    y
end

Base.showerror(io::IO, e::EquivalenceConversionQuantitiesError) =
    print(io, "EquivalenceConversionError: No available equivalence conversion function from $(e.x) to $(e.y).");

Base.showerror(io::IO, e::EquivalenceConversionFunctionError) =
    print(io, "EquivalenceConversionFunctionError: Equivalence conversion function '$(e.x)' does not accept unit '$(e.y)'.");

"""
    struct EquivalenceConversionStruct

Type for each equivalence conversion, with the conversion function `f_equiv`
that converts a quantity with units `u_in` into an equivalent quantity with
unit `u_out`.
"""
struct EquivalenceConversionStruct
    u_in :: Unitful.Units
    u_out :: Unitful.Units
    f_equiv :: Function
end

# Array with the list of EquivalenceConversionStruct available for equivalence conversion
equivalence_list = Array{Union{EquivalenceConversionStruct, Nothing}}(nothing,0)

"""
    add_equivalence(u_in::Unitful.Units, u_out::Unitful.Units, f_equiv::Function)

Add an equivalence conversion structure, with the given units and conversion function,
to the list `equivalence_list`.
"""
function add_equivalence(u_in::Unitful.Units, u_out::Unitful.Units, f_equiv::Function)
    global equivalence_list
    e = EquivalenceConversionStruct(u_in, u_out,f_equiv)
    equivalence_list = cat(equivalence_list, e, dims=1)
end

"""
    macro add_equivalence_macro(u_in, u_out, f_equiv)

Macro to simplify adding an equivalence conversion function to the `equivalence_list`,
by calling the function `add_equivalence`.
"""
macro equivalence(u_in, u_out, f_equiv)
    quote
        $add_equivalence($u_in, $u_out, $f_equiv)
    end
end

"""
    function econvert(a::Unitful.Units, x::Quantity{T,D,U}) where {T,D,U}

Convert a [`Unitful.Quantity`](@ref) `x` to a diferent unit `a` for which
there is an equivalence transformation given in the global list
`equivalence_list` of equivalence conversion transformation.

The conversion will fail if there is no equivalence transformation 
in the list associated with these quantities.

You can use this method to switch between representations of equivalent units,
like `°P` and `sg`:

Example:
```jldoctest
julia> econvert(u"P",1040u"sg")
9.992240000000066 °P

julia> econvert(u"sg", 10u"°P")
1.0400321211458716 sg
```

Or to convert from ppm or ppb to mg/L and back:

```jldoctest
julia> econvert(u"ppb", 0.1u"mg/L")
100.0 ppb

julia> econvert(u"mg/L", 10u"ppm")
10 mg L⁻¹
```
"""
function econvert(a::Unitful.Units, x::Quantity{T,D,U}) where {T,D,U}
    for e in equivalence_list
        if Unitful.dimension(e.u_in) == D && Unitful.dimension(e.u_out) == Unitful.dimension(a)
            if D == NoDims && Unitful.dimension(a) == NoDims
                if U() == e.u_in && a == e.u_out
                    return e.f_equiv(x)
                end
#            elseif D == NoDims && U() == e.u_in
#                return uconvert(a, e.f_equiv(x))
#            elseif Unitful.dimension(a) == NoDims && a == e.u_out
#                return e.f_equiv(uconvert(e.u_in, x))
            else
                return uconvert(a, e.f_equiv(uconvert(e.u_in, x)))
            end
        end
    end
    try
        Unitful.uconvert(a,x)
    catch
        throw(UnitfulBrew.EquivalenceConversionQuantitiesError(a, U()))
    end
end
