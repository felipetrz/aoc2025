import file_streams/file_stream
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string

pub fn main() -> Nil {
  let assert Ok(stream) = file_stream.open_read("input")
  let assert Ok(input) =
    file_stream.read_line(stream)
    |> result.map(string.trim_end)

  let result =
    string.split(input, on: ",")
    |> list.flat_map(fn(range) {
      let assert [start, end] = string.split(range, on: "-")
      let assert Ok(start) = int.parse(start)
      let assert Ok(end) = int.parse(end)
      list.range(start, end)
    })
    |> list.map(fn(value) {
      case is_invalid(value) {
        True -> echo value
        False -> 0
      }
    })
    |> int.sum()

  io.println("Result: " <> string.inspect(result))
}

fn is_invalid(value: Int) -> Bool {
  let value = string.to_graphemes(int.to_string(value))
  case list.length(value) {
    1 -> False
    l -> list.range(2, l) |> list.any(is_invalid_n(value, _))
  }
}

fn is_invalid_n(value: List(String), n: Int) -> Bool {
  let value_length = list.length(value)
  value_length >= n
  && value_length % n == 0
  && split_by_length(value, value_length / n)
  |> all_equal()
}

fn split_by_length(value: List(a), length: Int) -> List(List(a)) {
  case value {
    [] -> []
    value -> [
      list.take(value, length),
      ..split_by_length(list.drop(value, length), length)
    ]
  }
}

fn all_equal(value: List(a)) -> Bool {
  case value {
    [] -> True
    [_] -> True
    [one, two, ..rest] -> one == two && all_equal([two, ..rest])
  }
}
