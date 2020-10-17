class Point:
    def __init__(self, x, y):
        self.x = x
        self.y = y

    def draw(self):
        print(f"Point ({self.x}, {self.y})")

    def __str__(self):
        # return a string representation of this object
        return f"({self.x}, {self.y})"


point = Point(1, 2)
# point.__str__  # returns the name of our module and the memory address

# default implementation of the __str__ magic method in our object
# print(point)  # returns `<__main__.Point object at 0x10be29e80>`

print(point)  # returns `(1, 2)`

# we get the same result if you try to convert the point object to a string
# using the `str` function
print(str(point))
