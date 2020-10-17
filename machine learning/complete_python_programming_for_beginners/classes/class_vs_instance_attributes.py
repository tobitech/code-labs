class Point:
    # a class level attribute
    # we can read this via a class reference or an object reference
    default_color = "red"

    def __init__(self, x, y):
        self.x = x
        self.y = y

    def draw(self):
        print(f"Point ({self.x}, {self.y})")


point = Point(1, 2)

# we can always define attributes later even after creating the object
# point.z = 10

# this changes the value of the attribute across all instances
# because class level attributes are shared across all instances of a class
Point.default_color = "yellow"

# we can read the class attribute via an object reference
print(point.default_color)
# and also via a class reference
print(Point.default_color)

point.draw()

# completely independent of the first object
# each point have its own attributes
# these are instance attributes
another = Point(3, 4)
print(another.default_color)
another.draw()
