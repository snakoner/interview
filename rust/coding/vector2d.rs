
struct Vector2D {
    x: f32,
    y: f32,
}

impl Vector2D {
    fn new(x: f32, y: f32) -> Self {
        Self { x, y }
    }

    fn length(&self) -> f32 {
        (self.x * self.x + self.y * self.y).sqrt()
    }

    fn normalize(&mut self) {
        let length = self.length();
        self.x = self.x / length;
        self.y = self.y / length;
    }

    fn dot(&self, other: &Vector2D) -> f32 {
        self.x * other.x + self.y * other.y
    }
}


impl fmt::Display for Vector2D {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "({}, {})", self.x, self.y)
    }
}
