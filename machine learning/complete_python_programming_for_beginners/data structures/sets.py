numbers = [1, 1, 2, 3, 4]

# to remove duplicates in the list above, convert it to a set
first = set(numbers)
# print(first)

second = {1, 5}  # we use curly braces to define sets.
# second.add(5)  # add a new item to the set
# second.remove(1)  # remove an item
# len(second)  # get the length of a set
# print(second)

# Sets supports some powerful mathematical operators
# union of two sets
# returns all items that are either in the first or second set
print(first | second)

# intersection of two sets
# returns all items that are in both first and second sets
print(first & second)

# difference between two sets
print(first - second)

# symmetric difference
# returns items in the first or second set but not both
print(first ^ second)

# sets are unordered therefore does not support indexing
# print(first[0])  # returns a TypeError

# check for existence of item in a set
if 1 in first:
    print("yes")
