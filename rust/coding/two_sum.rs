use std::collections::HashMap;


fn two_sum(vec: &Vec<i32>, target: i32) -> Vec<i32> {
    let mut map: HashMap<i32, i32> = HashMap::new();

    for i in 0..vec.len() {
        let diff = target - vec[i];
        if let Some(value) = map.get(&diff) {
            return vec![*value, i as i32];
        }

        map.insert(vec[i], i as i32);
    }

    return vec![-1, -1];    
}

fn main() {
    let vec = vec![2,5,7,9];
    println!("{:?}", two_sum(&vec, 16)); // [2, 3]
}
