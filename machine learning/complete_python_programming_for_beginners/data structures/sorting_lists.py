numbers = [3, 51, 2, 8, 6]

# numbers.sort()  # sort list in ascending order

# numbers.sort(reverse=True)  # sort in descending order

# print(numbers)

# returns a new list that is sorted
# this will not modify the original list unlike `list.sort()`
# sorted(numbers)
# sorted(numbers, reverse=True)  # change the sort order

# sorting complex list of complex objects
items = [
    ("Product1", 10),
    ("Product2", 9),
    ("Product3", 12)
]
# items.sort()
# nothing is changed here because python doesn't know how to sort this list
# print(items)

# in cases like the above,
# we need to define a function that python will use to sort the list


def sort_item(item):
    # since it's a tuple we return the 2nd element,
    # so that python will use that to do the sorting.
    # in this case we are returning a number
    # and python know how to work with numbers
    return item[1]


items.sort(key=sort_item)  # we are passing a reference to `sort_item`
print(items)
