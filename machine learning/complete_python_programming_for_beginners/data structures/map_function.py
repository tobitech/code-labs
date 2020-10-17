items = [
    ("Product1", 10),
    ("Product2", 9),
    ("Product3", 12)
]

# say we want to transform the above list into a list of prices (numbers)
# prices = []
# for item in items:
#     prices.append(item[1])

# print(prices)

# returns a map object which is iterable
# x = map(lambda item: item[1], items)

# convert map object to a list
prices = list(map(lambda item: item[1], items))

print(prices)
