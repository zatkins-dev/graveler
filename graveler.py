from numpy.random import Generator, PCG64
from tqdm.contrib.concurrent import thread_map, process_map  # or thread_map


def roll_n(n):
    max_ones = 0
    rng = Generator(PCG64())

    for roll in range(1, n + 1):
        num_ones = sum(rng.integers(1, 5, size=231) == 1)
        max_ones = max(num_ones, max_ones)
        if max_ones >= 177:
            break
    return max_ones, roll


if __name__ == "__main__":
    # chuck size takes about 10 seconds to run
    chunk_size = int(100_000)
    max_rolls = int(1_000_000_000)
    result = process_map(roll_n, [chunk_size] * (max_rolls // chunk_size), chunksize=10)
    max_ones_list, num_rolls_list = zip(*result)
    max_ones = max(max_ones_list)
    num_rolls = sum(num_rolls_list)

    print("Highest Ones Roll:", max_ones)
    print("Number of Roll Sessions: ", num_rolls)
