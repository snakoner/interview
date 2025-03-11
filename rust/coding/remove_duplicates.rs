// @notice: removes duplicates from sorted array
fn remove_duplicates(vec: &mut Vec<i32>) -> usize {
    if vec.len() == 0 {
        return 0;
    }

    let mut prev = vec[0];
    let mut pos: usize = 1;

    for i in 1..vec.len() {
        if prev != vec[i] {
            vec[pos] = vec[i];
            pos += 1;
            prev = vec[i];
        }
    }

    pos
}

fn reverse_vector(vec: &mut Vec<i32>) {
    let len: usize = vec.len();
    for i in 0..len / 2 {
        vec.swap(i, len - i - 1);
    }
}

// @notice: not sorted vector
fn unique_vector(vec: &Vec<i32>) -> Vec<i32> {
    let mut unique: Vec<i32> = Vec::new();
    let mut map: HashMap<i32, usize> = HashMap::new();

    for i in 0..vec.len() {
        if let Some(value) = map.get(&vec[i]) {
            map.insert(vec[i], value + 1);
        } else {
            map.insert(vec[i], 1);
        }
    }

    for (key, value) in &map {
        if *value == 1 {
            unique.push(*key);
        }
    }
    
    return unique;
}
