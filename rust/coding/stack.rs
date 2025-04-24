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






// stack as list
#[derive(Debug)]
struct StackNode<T> {
    prev: Option<Box<StackNode<T>>>,
    value: T,
}

#[derive(Debug)]
struct Stack<T: Debug> {
    top: Option<Box<StackNode<T>>>,
    size: usize,
}

impl <T: Debug> Stack<T> {
    fn new() -> Self {
        Self { top: None, size: 0 }
    }

    fn push(&mut self, value: T) {
        let mut new_node: Box<StackNode<T>> = Box::new(StackNode {
            prev: None,
            value: value,
        });

        self.size += 1;
        if self.top.is_none() {
            self.top = Some(new_node);
            return;
        }

        let mut top = self.top.take();
        new_node.prev = top;
        self.top = Some(new_node);
    }

    fn print(&self) {
        let mut current = self.top.as_ref();
        while let Some(node) = current {
            print!("{:?} ", node.value);
            current = node.prev.as_ref();
        }
        println!();
    }

    fn len(&self) -> usize {
        self.size
    }

    fn empty(&self) -> bool {
        self.len() == 0
    }

    fn pop(&mut self) {
        if self.top.is_none() {
            return;
        }

        if self.len() == 1 {
            self.top.take();
        } else {
            let top = self.top.take();
            let prev = top.unwrap().prev;
            self.top = prev;
        }

        self.size -= 1;
    }

    fn peek(&self) -> Option<&T> {
        if self.empty() {
            return None;
        }

        let mut top = self.top.as_ref();
        let value = &top.unwrap().value;

        Some(value)
    }
}


fn main() {
    let mut stack: Stack<i32> = Stack::new();
    for i in 0..5 {
        stack.push(i);
    }

    stack.print();

    assert!(stack.len() == 5, "stack size is incorrent");

    while !stack.empty() {
        let value = stack.peek();
        match value {
            Some(val) => println!("{}", *val),
            None => println!("Value is none"),
        }

        stack.pop();
    }

    assert!(stack.empty(), "stack is not empty");
}
