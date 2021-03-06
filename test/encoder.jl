@testset "Encoder" begin

  o = Jib.Requests.Encoder.Enc()

  o(nothing, true, 1, 1.1, Jib.PRICE, :a, "test", (a=1, b="2"))

  m = split(String(take!(o.buf)), '\0')

  @test length(m) == 9
  @test m[1] == ""            # nothing
  @test m[2] == "1"           # Bool
  @test m[3] == "1"           # Int
  @test m[4] == "1.1"         # Float64
  @test m[5] == "1"           # Enum{Int32}
  @test m[6] == "a"           # Symbol
  @test m[7] == "test"        # String
  @test m[8] == "a=1;b=2;"    # NamedTuple
  @test m[9] == ""

  # Condition
  o(Jib.ConditionTime("o", true, "yyyymmdd"))
  @test String(take!(o.buf)) == "3\0o\x001\0yyyymmdd\0"

  # splat
  c = Jib.ComboLeg(conId=1, action="action")
  o(Jib.Requests.Encoder.splat(c, [1,3]),
    Jib.Requests.Encoder.splat(c))

  m = split(String(take!(o.buf)), '\0')
  @test m == ["1", "action", "1", "0", "action", "", "0", "0", "", "-1", ""]

  # Unsuported types
  @test_throws ErrorException o(Int32(2))
  @test_throws ErrorException o(Float32(1.))

end
