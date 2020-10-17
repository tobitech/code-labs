letters = ["a", "b", "c", "d"]
# print(letters[0])  # returns the first item
# print(letters[-1])  # returns the first item from the end of the list.

letters[0] = "A"
# print(letters)  # the first item has been modified `['A', 'b', 'c', 'd']`

# use two indexes to slice a list
print(letters[0:3])  # returns first three items
print(letters[:3])  # same as above
print(letters[0:])  # no end index returns all the items in the original list
print(letters[:])  # returns a copy of original list
print(letters)  # original list not modified

# you can pass a step when slicing a list
# say you want to return every second item in the original list
print(letters[::2])  # returns `['A', 'c']`

numbers = list(range(20))
print(numbers[::2])  # prints every other number in a new array
# returns all the items in the original list in reversed order
print(numbers[::-1])
