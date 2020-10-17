from array import array

numbers = array("i", [1, 2, 3])

# we have similar functions just as we have with list
numbers.append(4)  # add item to the end of array
numbers.insert(3, 4)
numbers.pop()  # remove last item
numbers[0]  # access item by its index

# however every item in an array is typed
# so you can't assign item in an array of integer to a floating point number
numbers[0] = 1.0  # throws TypeError
