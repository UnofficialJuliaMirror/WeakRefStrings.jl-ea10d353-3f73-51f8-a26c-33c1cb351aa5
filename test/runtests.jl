using WeakRefStrings, Missings, Compat, Compat.Test

@testset "WeakRefString{UInt8}" begin
    data = codeunits("hey there sailor")

    str = WeakRefStrings.WeakRefString(pointer(data), 3)

    @test str.len == 3
    @test string(str) == "hey"
    @test String(str) == "hey"

    io = IOBuffer()
    show(io, str)
    @test String(take!(io)) == "\"hey\""

    show(io, typeof(str))
    @test String(take!(io)) == "WeakRefString{UInt8}"
end

@testset "WeakRefString{UInt16}" begin
    # simulate UTF16 data
    data = [0x0068, 0x0065, 0x0079]

    str = WeakRefStrings.WeakRefString(pointer(data), 3)
    @test typeof(str) == WeakRefStrings.WeakRefString{UInt16}
    @test String(str) == "hey"
    @test str.len == 3
end

@testset "WeakRefString{UInt32}" begin
    # simulate UTF32 data with trailing null byte
    data = [0x00000068, 0x00000065, 0x00000079, 0x00000000]

    str = WeakRefStrings.WeakRefString(pointer(data), 4)
    @test typeof(str) == WeakRefStrings.WeakRefString{UInt32}
    @test String(str) == "hey"
    @test str.len == 4
end

@testset "WeakRefArray" begin
    data = codeunits("hey there sailor")
    str = WeakRefStrings.WeakRefString(pointer(data), 3)
    C = WeakRefStringArray(data, [str])
    @test length(C) == 1
    @test eltype(C) === String

    A = WeakRefStringArray(UInt8[], WeakRefStrings.WeakRefString{UInt8}, 10)
    @test size(A) == (10,)
    @test A[1] == ""
    @test A[1, 1] == ""
    A[1] = "hey"
    A[1, 1] = "hey"
    @test A[1] == "hey"
    resize!(A, 5)
    @test size(A) == (5,)
    push!(A, str)
    @test size(A) == (6,)
    @test A[end] == str
    push!(A, "hi")
    @test length(A) == 7
    @test A[end] == convert(WeakRefStrings.WeakRefString{UInt8}, "hi")

    B = WeakRefStringArray(UInt8[], WeakRefStrings.WeakRefString{UInt8}, 10)
    B[1] = "ho"
    append!(A, B)
    @test size(A) == (17,)

    D = WeakRefStringArray(UInt8[], Union{Missing, WeakRefStrings.WeakRefString{UInt8}}, 0)
    push!(D, "hey")
    push!(D, str)
    push!(D, missing)
    @test length(D) == 3
    @test eltype(D) == Union{Missing, String}
    @test D[2] == str
    @test D[3] === missing
    D[2] = missing
    @test D[2] === missing
    deleteat!(D, 1)
    @test length(D) == 2
    @test D[1] === missing

    E = WeakRefStringArray(data, [str missing])
    @test size(E) == (1, 2)
    @test eltype(E) === Union{String, Missing}

end
