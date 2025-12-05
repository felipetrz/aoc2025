import file_streams/file_stream
import gleam/bit_array
import gleam/int
import gleam/io
import gleam/list
import gleam/string

const input = "input"

pub fn main() -> Nil {
  let assert Ok(input) = file_stream.open_read(input)

  let fresh_ids = read_ranges(input)
  let ingredients = read_ingredients(input)
  let fresh_ingredients =
    ingredients |> list.count(is_fresh_ingredient(fresh_ids, _))
  io.println("fresh ingredients: " <> string.inspect(fresh_ingredients))

  let all_fresh = count_all_fresh(fresh_ids)
  io.println("all fresh: " <> string.inspect(all_fresh))

  Nil
}

type Range {
  Range(start: Int, end: Int)
}

fn read_ranges(input: file_stream.FileStream) -> List(Range) {
  let assert Ok(line) = file_stream.read_line(input)
  case line {
    "\n" -> []
    _ -> {
      let assert [start, end] = line |> string.trim() |> string.split("-")
      let assert Ok(start) = int.parse(start)
      let assert Ok(end) = int.parse(end)
      [Range(start, end), ..read_ranges(input)]
    }
  }
}

fn is_in_range(range: Range, id: Int) -> Bool {
  range.start <= id && id <= range.end
}

fn range_size(range: Range) -> Int {
  range.end - range.start + 1
}

fn combining_map(
  iter: List(a),
  state: List(a),
  combine: fn(a, List(a)) -> List(a),
) -> List(a) {
  case iter {
    [] -> state
    [a, ..rest] -> {
      combining_map(rest, combine(a, state), combine)
    }
  }
}

fn combine_ranges(a: Range, rest: List(Range)) -> List(Range) {
  case rest {
    [] -> [a]
    [b, ..rest] -> {
      let overap_start = int.max(a.start, b.start)
      let overlap_end = int.min(a.end, b.end)
      case overap_start <= overlap_end {
        True -> {
          let merge_start = int.min(a.start, b.start)
          let merge_end = int.max(a.end, b.end)
          combine_ranges(Range(merge_start, merge_end), rest)
        }
        False -> [b, ..combine_ranges(a, rest)]
      }
    }
  }
}

fn count_all_fresh(ranges: List(Range)) -> Int {
  let ranges = combining_map(ranges, ranges, combine_ranges)
  int.sum(list.map(ranges, range_size))
}

fn read_ingredients(input: file_stream.FileStream) -> List(Int) {
  let assert Ok(bytes) = file_stream.read_remaining_bytes(input)
  let assert Ok(string) = bit_array.to_string(bytes)
  string
  |> string.trim()
  |> string.split("\n")
  |> list.map(fn(value: String) -> Int {
    let assert Ok(value) = int.parse(value)
    value
  })
}

fn is_fresh_ingredient(ranges: List(Range), id: Int) -> Bool {
  ranges |> list.any(is_in_range(_, id))
}
