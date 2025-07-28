#[derive(Debug)]
struct ListNode {
    next: Option<Box<ListNode>>,
    value: i32,
}

#[derive(Debug)]
struct List {
    head: Option<Box<ListNode>>,
    size: usize,
}


impl List {
    fn new() -> Self {
        Self { head: None, size: 0, }
    }

    fn push(&mut self, value: i32) {
        let new_node = Box::new(ListNode{
            next: self.head.take(),
            value: value,
        });

        self.head = Some(new_node);
        self.size += 1;
    }

    fn empty(&self) -> bool {
        self.size == 0
    }

    fn size(&self) -> usize {
        self.size
    }

    fn pop(&mut self) {
        if self.empty() {
            return;
        }

        self.head = self.head.take().unwrap().next;
        self.size -= 1;
    }

    fn print(&self) {
        let mut current_node = self.head.as_ref();
        while let Some(node) = current_node {
            println!("{}", node.value);
            current_node = node.next.as_ref();
        }
    }
}




fn main() {
    let mut list = List::new();

    for i in 0..10 {
        list.push(i);
    }

    list.print();

    while !list.empty() {
        list.pop();
    }

    list.print();
}
