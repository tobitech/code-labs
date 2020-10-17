# class Point:
#     def __init__(self, x, y):
#         self.x = x
#         self.y = y

#     # we want to modify how python compares two instances of this class
#     def __eq__(self, other):
#         return self.x == other.x and self.y == other.y


# p1 = Point(1, 2)
# p2 = Point(1, 2)

# by default python compares objects based on where they are stored in memory
# since these two objects are stored in different places in memory,
# they are not equal
# print(p1 == p2)  # returns False

# id() returns the memory location of an object
# print(id(p1))
# print(id(p2))

# print(p1 == p2)  # returns True after implementing the __eq__ magic method


# instead of writing all the above for a class that only holds data
# we can use a named tuple instead

from collections import namedtuple

Point = namedtuple("Point", ["x", "y"])

# we can still call it to create a new Point object
# however we pass keyword arguments instead
# this makes our code more clear and less ambiguous
p1 = Point(x=1, y=2)
p2 = Point(x=1, y=2)

# we don't have to explicitly implement a magic method to compare two objects
print(p1 == p2)  # returns True

print(p1.x)  # returns 1 just like regular class attribute

# namedtuples are immutable
# you will have to create a new object if you want an object with a new value
# p1 = Point(x=10, y=2)
p1.x = 10  # throws an AttributeError: can't set attribute
