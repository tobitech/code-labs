letters = ["a", "b", "c"]  # a list of strings
matrix = [[0, 1], [2, 3]]  # a two dimensional list
zeros = [0] * 5  # 100  # repeat items in a list using `*`

# print(zeros)

# concatenate two lists with `+`
combined = zeros + letters  # returns `[0, 0, 0, 0, 0, 'a', 'b', 'c']`
# print(combined)

# list function takes in an iterable
# this takes a range and creates a list from `0 - 20`
numbers = list(range(20))
# print(numbers)

chars = list("Hello World")  # remember a string is also iterable
# this prints `['H', 'e', 'l', 'l', 'o', ' ', 'W', 'o', 'r', 'l', 'd']`
print(chars)

# get the number of items in a list with `len()`
print(len(chars))
