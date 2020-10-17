letters = ["a", "b", "c"]

print(letters.index("a"))  # get the index of an object in a list
# print(letters.index("d"))  # you get a ValueError for object not in list

if "d" in letters:  # `in` operator to check if object is in list
    print(letters("d"))

# returns the number of occurences of a given item in a list
print(letters.count("a"))
