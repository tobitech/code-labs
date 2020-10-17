list1 = [1, 2, 3]
list2 = [10, 20, 30]

# here is the result we want to achieve
# to combine the elements of the lists into a list of tuples
[(1, 10), (2, 20), (3, 30)]

print(list(zip(list1, list2)))
print(list(zip("abc", list1, list2)))
