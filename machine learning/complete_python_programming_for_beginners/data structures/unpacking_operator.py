numbers = [1, 2, 3]
# print(numbers)  # `[1, 2, 3]`

# what if we want to print out individual numbers like this:
# with no square brackets and no commas
# print(1, 2, 3)  # `1 2 3`

# we can use the unpacking operator
# print(*numbers)

# we can use it for lists as well
# values = list(range(5))
# print(values)

# instead of calling the list() function
# we can use the unpacking operator
# values = [*range(5), *"Hello"]  # we can unpack any iterable.
# print(values)

# we can combine multiple lists with this operator
# first = [1, 2]
# second = [3]
# # values = [*first, *second]
# values = [*first, "a", *second, *"Hello"]
# print(values)

# we can do the same for dictionaries but with the use of `**`
first = {"x": 1}

# if you have multiple items with the same key the last value would be used
second = {"x": 10, "y": 2}
# combined = {**first, **second}
combined = {**first, **second, "z": 1}
print(combined)
