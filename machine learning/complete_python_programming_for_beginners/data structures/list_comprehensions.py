items = [
    ("Product1", 10),
    ("Product2", 9),
    ("Product3", 12)
]

# prices = list(map(lambda item: item[1], items))

# the above line can be written with comprehension
prices = [item[1] for item in items]  # shorter and cleaner

# filtered = list(filter(lambda item: item[1] >= 10, items))

# syntax: [expression for item in items]
# expression is what you want to return
# if item[1] >= 10 is the computation you want to run
# on what you are returning
filtered = [item for item in items if item[1] >= 10]
