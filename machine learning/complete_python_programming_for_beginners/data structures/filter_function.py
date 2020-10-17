items = [
    ("Product1", 10),
    ("Product2", 9),
    ("Product3", 12)
]

# say we want to get items with price greater than or equal to $10
filtered = list(filter(lambda item: item[1] >= 10, items))
print(filtered)
