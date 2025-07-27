use std::collections::HashMap;

fn word_count(s: &str, sep: char) -> HashMap<String, usize> {
    let mut res_s: String = String::new();
    let mut hm: HashMap<String, usize> = HashMap::new();
    for ch in s.chars() {
        if ch == sep {
            *hm.entry(res_s.clone()).or_insert(0) += 1;
            res_s.clear();
        } else {
            res_s.push(ch);
        }
    }

    if res_s.len() != 0 {
            *hm.entry(res_s.clone()).or_insert(0) += 1;
    }

    hm
}



fn main() {
    let s = "Hello my friend friend friend";

    println!("{:?}", word_count(&s, ' '));
}
