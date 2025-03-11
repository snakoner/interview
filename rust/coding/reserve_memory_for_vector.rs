fn concat_vectors(a: &Vec<i32>, b: &Vec<i32>) -> Vec<i32> {
    let mut result: Vec<i32> = Vec::with_capacity(a.len() + b.len());
    
    for i in 0..a.len() {
        result.push(a[i]);
    }

    for i in 0..b.len() {
        result.push(b[i]);
    }

    return result;
}

fn main() {
    let a: Vec<i32> = vec![1, 2, 3, 4, 5];
    let b: Vec<i32> = vec![6, 7, 8, 9];
    let concated_vec = concat_vectors(&a, &b);

    println!("{:?}, len = {}, cap = {}", concated_vec, concated_vec.len(), concated_vec.capacity()); // [1, 2, 3, 4, 5, 6, 7, 8, 9], len = 9, cap = 9
}
