# values = []
# for x in range(5):
#     values.append(x * 2)

# remember we can rewrite the above with map or comprehension (prefarable)
# with the syntax below
# [expression for item in items]

# here it is
# values = [x * 2 for x in range(5)]  # same as the above first 3 lines

# we can also use comprehensions with sets and dictionaries
# values = {x * 2 for x in range(5)}  # use of curly braces makes this a set
# print(values)

# just modify the expression part of the comprehension by adding a key
# to get a dictionary. here we are using `x` values as keys
# values = {x: x * 2 for x in range(5)}
# print(values)

# change curly braces to parenthesis
values = (x * 2 for x in range(5))
print(values)  # returns a generator object
