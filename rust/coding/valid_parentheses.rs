
// {{()}}
fn valid_parentheses(s: &str) -> bool {
    let chars = s.chars();
    let mut stack: Vec<char> = Vec::new();

    for c in s.chars() {
        match c {
            '(' => stack.push(')'),
            '{' => stack.push('}'),
            '[' => stack.push(']'),
            _ => {
                if Some(c) != stack.pop() {
                    return false;
                }
            }
        }
    }
    stack.is_empty()
}

fn main() {
    assert!(valid_parentheses("((({{{}}})))") == true);
    assert!(valid_parentheses("((({{{]})))") == false);
}   
