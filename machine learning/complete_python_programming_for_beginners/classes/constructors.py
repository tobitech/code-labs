class Point:
    # `self` is a reference to the current object
    def __init__(self, x, y):
        # `x` and `y` are new attributes we are adding to the object
        # using the passed values to set them
        self.x = x
        self.y = y

    # we have a reference to the current object here with `self`
    # with that we can read the current values for `x` and `y`
    # defined in the constructor
    def draw(self):
        # using self we can read attributes in the object
        # or also call other methods in this object
        print(f"Point ({self.x}, {self.y})")


point = Point(1, 2)
# print(point.x)  # `x` not available to the object
point.draw()
