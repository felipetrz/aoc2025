import file_streams/file_stream
import gleam/bit_array
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/pair
import gleam/string
import iterators

const input = "input"

pub fn main() -> Nil {
  let cache = dict.new()

  let assert Ok(input) = file_stream.open_read(input)
  let assert Ok(input) = file_stream.read_remaining_bytes(input)
  let assert Ok(input) = bit_array.to_string(input)

  let result =
    input
    |> string.trim()
    |> string.split("\n")
    |> iterators.from_list()
    |> iterators.map(fn(line: String) -> List(Int) {
      line
      |> string.to_graphemes()
      |> list.map(fn(value: String) {
        let assert Ok(value) = int.parse(value)
        value
      })
    })
    |> iterators.map(find_max_joltage(_, 12, cache))
    |> iterators.fold(0, fn(value, acc) { value + pair.first(acc) })

  io.println("result: " <> string.inspect(result))

  Nil
}

type Cache =
  dict.Dict(#(List(Int), Int), Int)

fn find_max_joltage(bank: List(Int), n: Int, cache: Cache) -> #(Int, Cache) {
  case n <= 0 || list.length(bank) < n {
    True -> #(0, cache)
    False -> {
      case dict.get(cache, #(bank, n)) {
        Ok(cached) -> #(cached, cache)
        Error(Nil) -> {
          let assert Ok(first) = list.first(bank)
          let assert Ok(rest) = list.rest(bank)

          let #(a, cache) = find_max_joltage(rest, n - 1, cache)
          let a = int_power(10, n - 1) * first + a

          let #(b, cache) = find_max_joltage(rest, n, cache)

          let r = int.max(a, b)
          #(r, dict.insert(cache, #(bank, n), r))
        }
      }
    }
  }
}

fn int_power(base: Int, exp: Int) -> Int {
  case exp {
    0 -> 1
    1 -> base
    _ -> base * int_power(base, exp - 1)
  }
}
