letters = ["a", "b", "c"]

# Add
letters.append("d")  # add an item to the end of the list
letters.insert(0, "-")  # add an item at a particular index
print(letters)

# Remove
letters.pop()  # remove the very last item
letters.pop(1)  # remove item at an index

# remove item if you don't know the index
# this removes the first occurence of the letter "b"
# if you have multiple "b"s only the first one will be removed
# if you want to remove all "b"s in that case,
# you will have to loop over the list
letters.remove("b")

del letters[0]  # delete an item
del letters[0:3]  # delete a range of items

letters.clear()  # remove all items in the list
