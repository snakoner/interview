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
