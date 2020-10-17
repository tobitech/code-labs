items = [
    ("Product1", 10),
    ("Product2", 9),
    ("Product3", 12)
]


# def sort_item(item):
#     return item[1]


# items.sort(key=sort_item)  # we are passing a reference to `sort_item`
# print(items)

# we don't have to define the `sort_item` function first and pass it
# here is a cleaner way
items.sort(key=lambda item: item[1])
print(items)
