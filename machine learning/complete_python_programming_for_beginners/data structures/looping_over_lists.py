letters = ["a", "b", "c"]

# for letter in letters:
#     print(letter)

# to get the index of each item we use enumerate()
# for letter in enumerate(letters):
#     print(letter[0], letter[1])  # returns a tuple: `(0, a)`

# we can unpack the tuple enumerate() returns on each iteration
for index, letter in enumerate(letters):
    print(index, letter)
