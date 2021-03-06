module Encoder

import ...AbstractCondition

# Splat fields
splat(x, idx=fieldnames(typeof(x))) = (getfield(x, i) for i ∈ idx)

"""
    Enc()

Wrap an `IOBuffer` to hold the outbound message
"""
struct Enc
  buf::IOBuffer
end
Enc() = Enc(IOBuffer(sizehint=64))


"""
    (e::Enc)(::T)

Define various encodings for known types
"""
(e::Enc)(::T) where T = error("Unknown Type: $T")

(e::Enc)(x::Union{AbstractString,Int,Float64,Symbol}) = print(e.buf, x, '\0')

(e::Enc)(::Nothing) = e("")

(e::Enc)(x::Bool) = e(x ? "1" : "0")

# Enums
(e::Enc)(x::Enum{Int32}) = e(Int(x))

# NamedTuples
function (e::Enc)(x::NamedTuple)

  for (n, v) ∈ pairs(x)
    v isa Union{AbstractString,Int,Float64} ||
      @warn "Unsupported Type in NamedTuple" N=n V=v T=typeof(v)

    print(e.buf, n, '=', v, ';')
  end

  print(e.buf, '\0')
end

# Condition Types
(e::Enc)(x::AbstractCondition{E}) where E = e(E, splat(x))

# Generators, as returned by splat()
(e::Enc)(x::Base.Generator) = foreach(e, x)

# Multiple arguments
function (e::Enc)(x, y...)
  e(x)
  foreach(e, y)
end

end
