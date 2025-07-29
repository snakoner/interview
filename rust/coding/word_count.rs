use std::collections::HashMap;

fn words_count(s: &str) -> HashMap<&str, usize> {
    let mut hm: HashMap<&str, usize> = HashMap::new();
    let mut pos = 0;
    let mut prev_char = false;
    for (i, ch) in s.chars().enumerate() {
        if ch == ' ' {
            if prev_char {
                *hm.entry(&s[pos..i]).or_insert(0) += 1;
            }
            
            pos = i + 1;
            prev_char = false;
            continue;
        }
        prev_char = true;
    }

    if pos != s.len() {
        *hm.entry(&s[pos..]).or_insert(0) += 1;
    }

    hm
}

fn main() {
    let s = String::from("Hello my friend friend friend");

    println!("{:?}", words_count(&s, ' '));
}
