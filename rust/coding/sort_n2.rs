fn insertion_sort(vec: &mut Vec<i32>) {
    for i in 0..vec.len() - 1 {
        let mut j = i + 1;
        while j > 0 {
            if vec[j] < vec[j - 1] {
                vec.swap(j, j - 1);
            }
            j -= 1;
        }
    }
}


fn bubble_sort(vec: &mut Vec<i32>) {
    for i in 0..vec.len() {
        let mut break_ = true;
        for j in 0..vec.len() - i - 1 {
            if vec[j] > vec[j + 1] {
                vec.swap(j, j + 1);
                break_ = false;
            }
        }

        if break_ {
            return;
        }
    }
}

fn selection_sort(vec: &mut Vec<i32>) {
    for i in 0..vec.len() {
        let mut min = i;
        for j in i..vec.len() {
            if vec[min] > vec[j] {
                min = j;
            }
        }
        if i != min {
            vec.swap(i, min);
        }
    }
}


fn is_sorted(vec: &Vec<i32>) -> bool {
    for i in 0..vec.len() - 1 {
        if vec[i] > vec[i + 1] {
            return false;
        }
    }

    true
}



fn main() {
    let mut errors = 0;
    {
        let mut vec = vec![4,3,1,6,44,4,33];
        bubble_sort(&mut vec);
        if !is_sorted(&vec) {
            errors += 1;
        }
    }
    {
        let mut vec = vec![4,3,1,6,44,4,33];
        selection_sort(&mut vec);
        if !is_sorted(&vec) {
            errors += 1;
        }
    }
    {
        let mut vec = vec![4,3,1,6,44,4,33];
        insertion_sort(&mut vec);
        if !is_sorted(&vec) {
            errors += 1;
        }
    }

    assert!(errors == 0);
}   
