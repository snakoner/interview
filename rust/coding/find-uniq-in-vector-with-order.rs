fn find_unique<T: Hash + Eq + Copy>(vec: &[T]) -> Vec<T> {
    if vec.len () == 0 {
        return Vec::new();
    }

    let mut hm: HashMap<T, usize> = HashMap::new();
    let mut pos = 0;
    for value in vec {
        if !hm.contains_key(value) {
            hm.insert(*value, pos);
            pos += 1;
        }
    }

    let val = vec[0];
    let mut result = vec![val; hm.len()];
    for (k, v) in &hm {
        result[*v] = *k;
    }

    result
}

fn main() {
    let mut vec = vec![1,1,2,2,5,5,3,3,2];
    let res = find_unique(&vec);

    println!("{res:?}");
}
