class Point:
    def __init__(self, x, y):
        self.x = x
        self.y = y

    # when creating a class method
    # we pass in a first parameter `cls`
    # it can be named anything. `cls` is just a convention
    # this is a reference to the class itself
    @classmethod  # this decorator is used to mark a method as class method
    def zero(cls):
        # same as calling `return Point(0, 0)`
        # at runtime, when you call the zero() method
        # python interpreter will automatically pass a reference
        # to the Point class to the zero method
        return cls(0, 0)

    def draw(self):
        print(f"Point ({self.x}, {self.y})")


point = Point.zero()
point.draw()
