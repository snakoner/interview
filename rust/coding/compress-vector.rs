fn compress(vec: &Vec<i32>) -> Vec<(i32, usize)> {
    let mut result: Vec<(i32, usize)> = Vec::new();
    if vec.len() == 0 {
        return result;
    }
    
    let mut prev = vec[0];
    let mut count = 1;
    for i in 1..vec.len() {
        if vec[i] == prev {
            count += 1;
        } else {
            result.push((prev, count));
            prev = vec[i];
            count = 1;
        }
    }

    result.push((prev, count));

    result
}

fn main() {
    let data = vec![1, 1, 2, 2, 2, 3, 1, 1,2];
    let result = compress(&data);

    for value in result.iter() {
        println!("{value:?}");
    }
}
