using Distributed
num_procs = 24
addprocs(num_procs)

@everywhere using Distributed
@everywhere using ProgressBars
@everywhere using Random


@everywhere roll(rng, a) = sum(rand!(rng, a, 1:4) .== 1)

@everywhere function roll_chunk(chunk_size::Int; target::Int=177)
  # Initialize RNG and array to store values
  # This is faster than using rand without an RNG, since we don't have to recreate it each time
  rng = TaskLocalRNG()
  a = zeros(UInt8, 231)
  max_ones = 0
  num_rolls = 0
  while max_ones < target && num_rolls < chunk_size
    max_ones = max(max_ones, roll(rng, a))
    num_rolls += 1
  end
  return max_ones, num_rolls
end

@everywhere reduce_chunk_sums(lhs, rhs) = max(first(lhs), first(rhs)), last(lhs) + last(rhs)

let
  n = Int(1e9)
  chunk_size = n ÷ num_procs
  @time values = Distributed.pmap(roll_chunk, fill(chunk_size, num_procs))
  max_ones, num_rolls = Iterators.reduce(reduce_chunk_sums, values)
  println("Max ones: $max_ones")
  println("Num rolls: $num_rolls")
end
