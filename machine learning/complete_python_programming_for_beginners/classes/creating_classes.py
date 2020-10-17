class Point:
    # every method in a class must have at least one parameter
    # we call it `self`
    def draw(self):
        print("draw")


point = Point()  # this is how we create a `Point Object`
point.draw()  # the new object has the draw method

# returns `<class '__main__.Point'>`
# the `__main__` shows that we are in the main module
print(type(point))

# check if an object is an instance of a given class
print(isinstance(point, Point))  # returns `True`
