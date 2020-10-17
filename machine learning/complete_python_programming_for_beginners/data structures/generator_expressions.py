from sys import getsizeof

# values = [x * 2 for x in range(10)]
# for x in values:
#     print(x)


# when you need to store large dataset like a range of 10million
# use generator objects.
values = (x * 2 for x in range(100000))  # values is now a generator object

# for x in values:
#     print(x)  # returns the same values as the above first 3 lines

print("gen:", getsizeof(values))  # gen: 112 bytes

# returns TypeError: object of type 'generator' has no len()
print(len(values))

# values = [x * 2 for x in range(100000)]
# print("list:", getsizeof(values))  # list: 824456 bytes
