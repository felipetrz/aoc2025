use std::io::BufRead;
use std::io::BufReader;

use anyhow::Result;
use itertools::Itertools;
use ndarray::prelude::*;
use thiserror::Error;

const INPUT_PATH: &str = "input";

#[derive(Debug, Clone, Copy)]
enum GridCell {
    Free,
    Roll,
}

#[derive(Debug, Error)]
enum GridError {
    #[error("invalid character: {0}")]
    InvalidCharacter(char),
}

fn main() -> Result<()> {
    let file = std::fs::File::open(INPUT_PATH)?;
    let reader = BufReader::new(file);

    let grid: Vec<Vec<GridCell>> = reader
        .lines()
        .map(|line| -> Result<_> {
            let line = line?;
            line.chars()
                .map(|c| {
                    Ok(match c {
                        '.' => GridCell::Free,
                        '@' => GridCell::Roll,
                        _ => return Err(GridError::InvalidCharacter(c).into()),
                    })
                })
                .try_collect()
        })
        .try_collect()?;

    let shape = (grid.len(), grid[0].len());
    let flat: Vec<GridCell> = grid.iter().flatten().copied().collect();
    let mut grid = Array::from_shape_vec(shape, flat)?;

    let mut total_count = 0;

    loop {
        let mut neigh = Array::from_shape_simple_fn(shape, || 0);

        for y in 0..grid.shape()[0] {
            for x in 0..grid.shape()[1] {
                if let GridCell::Roll = grid[[y, x]] {
                    for dy in -1..=1 {
                        let ty = y as isize + dy;
                        if ty < 0 || ty >= grid.shape()[0] as isize {
                            continue;
                        }
                        let ty = ty as usize;

                        for dx in -1..=1 {
                            let tx = x as isize + dx;
                            if tx < 0 || tx >= grid.shape()[1] as isize {
                                continue;
                            }
                            let tx = tx as usize;

                            if (ty, tx) == (y, x) {
                                continue;
                            }

                            if let GridCell::Roll = grid[[ty, tx]] {
                                neigh[[ty, tx]] += 1;
                            }
                        }
                    }
                }
            }
        }

        let mut count = 0;
        for y in 0..grid.shape()[0] {
            for x in 0..grid.shape()[1] {
                if let GridCell::Roll = grid[[y, x]]
                    && neigh[[y, x]] < 4
                {
                    grid[[y, x]] = GridCell::Free;
                    count += 1;
                }
            }
        }

        if count == 0 {
            break;
        }

        total_count += count;
    }

    println!("result: {total_count:?}");

    Ok(())
}
