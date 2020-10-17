import random
import string

# generates a random value between 0 and 1
# print(random.random())  # returns a floating point number

# generates a random integer between two numbers
# print(random.randint(1, 10))

# randomly picks one of the items in a list
# print(random.choice([1, 2, 3, 4]))

# returns a number of random items from a list
# e.g. returns 2 random items from the list
# print(random.choices([1, 2, 3, 4], k=2))

# with `choices()` we can generate a random password
# e.g. generate a password of 4 characters
# print(random.choices(
# "abcdefghijklmnopqrstuvwxyzABCDEFGHOIJKLMNOPQRSTUVWXYZ0123456789
# !@#$%^&*()_-{}[]+=\|?/>.<,`~", k=4))

# you can join the sequence with join()
# print("".join(random.choices("abcdefghijklmnopqrstuvwxyz", k=4)))

# for comma separated join
# print(",".join(random.choices("abcdefghijklmnopqrstuvwxyz", k=4)))

# print(string.ascii_letters)  # returns alphabets in lower and upper cases
# print(string.digits)  # returns 0123456789

# we can rewrite the above like:
# print("".join(random.choices(string.ascii_letters + string.digits, k=4)))

# we can suffle a list with
numbers = [1, 2, 3, 4]
random.shuffle(numbers)
print(numbers)  # the order of the items are randomly changed
