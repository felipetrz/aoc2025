use std::error::Error;
use std::io::BufRead;
use std::io::BufReader;

fn main() -> Result<(), Box<dyn Error>> {
    let file = std::fs::File::open("input")?;
    let reader = BufReader::new(file);

    let mut dial = 50;
    let mut password = 0;

    for line in reader.lines() {
        let line = line?;

        let mut chars = line.chars();
        let direction = chars.next().unwrap();
        let amount: i32 = chars.as_str().parse()?;

        match direction {
            'L' => {
                if dial == 0 {
                    dial = 100;
                }
                dial -= amount;
                while dial < 0 {
                    dial += 100;
                    password += 1;
                }
                if dial == 0 {
                    password += 1;
                }
            }
            'R' => {
                dial += amount;
                while dial >= 100 {
                    dial -= 100;
                    password += 1;
                }
            }
            _ => {}
        }

        println!("{direction} {amount} -> {dial} ({password})")
    }

    println!("{password}");

    Ok(())
}
