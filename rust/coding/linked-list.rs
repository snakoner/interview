struct ListNode {
    next: Option<Box<ListNode>>,
    value: i32,
}

impl ListNode {
    fn new(value: i32) -> Self {
        Self { next: None, value: value }
    }
}

struct List {
    head: Option<Box<ListNode>>,
    size: i32,
}

impl List {
    fn new() -> Self {
        Self { head: None, size: 0 }
    }

    fn push(&mut self, value: i32) {
        let mut new_node:Box<ListNode> = Box::new(ListNode::new(value));
        self.size += 1;
        if self.head.is_none() {
            self.head = Some(new_node);
            return;
        }

        let current_node = self.head.take();
        new_node.next = current_node;
        self.head = Some(new_node);
    }

    fn print(&self) {
        let mut current = self.head.as_ref();
        while let Some(node) = current {
            print!("{} ", node.value);
            current = node.next.as_ref();
        }
    }

    fn top(&self) -> Option<i32> {
        self.head.as_ref().map(|node| node.value)
    }

    fn pop(&mut self) {
        if self.head.is_none() {
            return;
        }        

        let head = self.head.take();
        let next = head.unwrap().next;
        self.head = next;
        self.size -= 1;
    } 

    fn len(&self) -> usize {
        self.size as usize
    }

    fn empty(&self) -> bool {
        self.len() == 0
    }
}


fn main() {
    let mut list = List::new();

    for i in 0..5 {
        list.push(i);
    }

    while !list.empty() {
        let value = list.top();
        match value {
            Some(v) => println!("{v} "),
            None => println!("Value is none"),
        }

        list.pop();
    }

    // list.print();
}   
