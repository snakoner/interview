struct Stack {
    elements: Vec<i32>,
}

impl Stack {
    fn new() -> Self {
        Self { elements: Vec::new(), }
    }

    fn len(&self) -> i32 {
        self.elements.len() as i32
    }

    fn push(&mut self, value: i32) {
        self.elements.push(value);
    }

    fn pop(&mut self) -> Option<i32> {
        self.elements.pop()
    }

    fn empty(&self) -> bool {
        self.len() == 0
    }

    fn peek(&self) -> Option<i32> {
        if self.len() == 0 {
            return None;
        }

        return Some(self.elements[(self.len() - 1) as usize])
    }

    fn to_string(&self) -> String {
        let mut s = String::new();
        for num in &self.elements {
            let new_s = String::from(num.to_string());
            s.push_str(&new_s);
            s.push(' ');
        }

        s
    }
}

fn main() {
    let mut stack = Stack::new();
    for i in 0..5 {
        stack.push(i);
    }

    println!("{}", stack.to_string());

    while !stack.empty() {
        let val: Option<i32> = stack.pop();
        println!("{:?}", val.unwrap());
    }

    println!("{}", stack.len());
}
