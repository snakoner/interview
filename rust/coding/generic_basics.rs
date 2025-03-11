fn max<T: PartialOrd + Copy>(vec: Vec<T>) -> Option<T> {
    let mut result: Option<T> = None;
    if vec.len() == 0 {
        return result;
    }

    let mut max: T = vec[0];
    for i in 1..vec.len() {
        if vec[i] > max {
            max = vec[i];
        }
    }   

    result = Some(max);
    result
}


fn main() {
    let vec: Vec<i32>  = vec![5,4,1,6,8,4,2,22];

    let result = max(vec);
    if let Some(value) = result {
        println!("max is {value}");
    } else {
        println!("none");
    }

    let vec: Vec<i64> = vec![5,4,1,6,8,4,2,22];
    
    let result = max(vec);
    if let Some(value) = result {
        println!("max is {value}");
    } else {
        println!("none");
    }
}
