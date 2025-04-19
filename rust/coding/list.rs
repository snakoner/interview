
#[derive(Debug)]
struct ListNode {
    next: Option<Box<ListNode>>,
    value: i32
}

impl ListNode {
    fn new(value: i32) -> Self {
        Self { next: None, value: value }
    }
}

#[derive(Debug)]
struct List {
    head: Option<Box<ListNode>>,
    size: usize
}

impl List {
    fn new() -> Self {
        Self { head: None, size: 0 }
    }

    fn len(&self) -> usize {
        self.size
    }

    fn push(&mut self, value: i32) {
        self.size += 1;
        let new_node = Box::new(ListNode::new(value));
        if let None = self.head {
            self.head = Some(new_node);
            return;
        }

        let mut current = &mut self.head;
        while let Some(ref mut node) = *current {
            if node.next.is_none() {
                node.next = Some(new_node);
                return;
            }
            current = &mut node.next; 
        }
    }

    fn println(&mut self) {
        let mut current = &mut self.head;
        while let Some(ref mut node) = current {
            print!("{} ", node.value);
            current = &mut node.next;
        }
    }

    fn pop(&mut self) {

    }
}
