# point = {"x": 1, "y": 2}  # define a dictionary
# print(type(point))

# list()
# tuple()
# set()

# just as we have those built in functions above we have for dictionary

# define dictionary with keyword arguments
# prefarable because no quotes
point = dict(x=1, y=2)

# get value at an index. index is a name of a key
# print(point["x"])  # get the value of "x"

point["x"] = 10  # change the valyu of "x"

point["z"] = 20  # add a new key to the dictionary

# you get KeyError for trying to access a key that doesn't exist
# print(point["a"])

# solution1: check for the existence of a key
if "a" in point:
    print(point["a"])

# solution2: use `get()` method
# print(point.get("a"))  # returns `None` if key doesn't exist

# pass a default that will be returned if key doesn't exist
print(point.get("a", 0))

# delete an item
del point["x"]

print(point)

# looping through dictionaries
# for key in point:  # loops through the keys of the dictionaries
#     print(key, point[key])  # print key and value of key

# for x in point.items():
#     print(x)  # we get a tuple of the (key, value)

# so we can unpack the tuple
for key, value in point.items():
    print(key, value)
