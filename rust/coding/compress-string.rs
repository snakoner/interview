fn compress_string(s: &str) -> String {
    let mut res = String::new();
    let mut counter = 0;
    if s.len() <= 1 {
        return String::from(s);
    }

    let mut prev = s.chars().next().unwrap();
    for ch in s.chars() {
        if ch == prev {
            counter += 1;
        } else {
            res.push(prev);
            if counter > 1 {
                res.push(char::from_digit(counter, 10).unwrap());
            }

            counter = 1;
            prev = ch;
        }
    }

    res.push(prev);
    if counter > 1 {
        res.push(char::from_digit(counter, 10).unwrap());
    }

    res
}

fn decompress_string(s: &str) -> String {
    let mut result = String::new();
    if s.len() <= 1 {
        return String::from(s);
    }

    let mut prev = s.chars().next().unwrap();
    for ch in s.chars() {
        if ch.is_alphabetic() {
            result.push(ch);
            prev = ch;
        } else {
            let value = ch.to_digit(10).unwrap();
            for _ in 0..value - 1 {
                result.push(prev);
            }
        }                     
    }

    result
}

fn main() {
    assert_eq!(compress_string("heeellllooo"), "he3l4o3");
    assert_eq!(compress_string("h"), "h");
    assert_eq!(compress_string("hhha"), "h3a");
    assert_eq!(compress_string("heeellllo"), "he3l4o");
    assert_eq!(compress_string(""), "");

    {
        let s = "heeellllooo";
        let decompressed_string = decompress_string(&compress_string(s));
        assert_eq!(s, decompressed_string);
    }

    {
        let s = "hhha";
        let decompressed_string = decompress_string(&compress_string(s));
        assert_eq!(s, decompressed_string);
    }

    {
        let s = "h";
        let decompressed_string = decompress_string(&compress_string(s));
        assert_eq!(s, decompressed_string);
    }
    {
        let s = "heeellllo";
        let decompressed_string = decompress_string(&compress_string(s));
        assert_eq!(s, decompressed_string);
    }
    {
        let s = "";
        let decompressed_string = decompress_string(&compress_string(s));
        assert_eq!(s, decompressed_string);
    }
}
