numbers = [1, 2, 3, 4, 4, 4, 4, 4, 4, 9]

# say you want to use each item in a variable
# first = numbers[0]
# second = numbers[1]
# third = numbers[2]

# cleaner way to do it is to unpack the numbers list.
# first, second, third = numbers  # list unpacking
# the number of variables should be equal to the number of items in the list

# first, second = numbers  # returns ValueError: too many values to unpack

# we unpack the first two items and the remaining in another list
first, second, *other = numbers
print(first)
print(other)

# if we only care about the first and last item
# we can pack what's in between in another list as shown below
first, *other, last = numbers
print(last)
print(other)
