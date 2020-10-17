# point = (1, 2)
# point = 1, 2  # we can also exclude the parenthesis
# print(type(point))  # returns `<class 'tuple'>`
# point = 1, # if the tuple has one item make sure to add a trailing comma
# point = ()  # define an empty tuple

# concatenate two tuples
# point = (1, 2) + (3, 4)
# print(point)

# repeat a tuple with `*`
# point = (1, 2) * 3  # returns `(1, 2, 1, 2, 1, 2)`
# print(point)

# convert a list to a tuple
# point = tuple([1, 2])  # tuple function takes an iterable
# point = tuple("Hello World")
# print(point)

# access individual item using an index
point = (1, 2, 3)
# print(point[0])
print(point[0:2])  # returns another tuple with items in the selected range

# unpack tuple
x, y, z = point
print(x)

# check for existence of an item in a tuple
print(2 in point)

# tuples are immutable
# you get a TypeError if you try to modify a tuple
point[0] = 10
