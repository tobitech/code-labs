import numpy as np  # use of alias to shorten module import

# array = np.array([1, 2, 3])
# print(array)
# print(type(array))  # returns `<class 'numpy.ndarray'>`

# creating multi-dimensional array
# this is a 2D array or a matrix in mathematics
# this is a matrix with 2-rows and 3-columns
# array = np.array([[1, 2, 3], [4, 5, 6]])
# print(array)

# returns a tuple that specifies the number of items in each dimension
# print(array.shape)  # returns `(2, 3)`

# some interesting methods in numpy to create arrays

# this creates an array and initializes it with zeros
# takes a shape tuple argument
# by defaulf the 0s are floating point numbers
# array = np.zeros((3, 4))

# pass a second argument to change the data type
# array = np.zeros((3, 4), dtype=int)

# initialize array with 1s
# array = np.ones((3, 4), dtype=int)

# fill array with any other number
# array = np.full((3, 4), fill_value=5, dtype=int)

# create an array with random values
# array = np.random.random((3, 4))

# print(array)

# we can access individual element using an index
# get element at first row and first column
# print(array[0, 0])

# returns whether each corresponding element in the multi-dimensional array
# is greater than 0.2
# print(array > 0.2)

# boolean indexing. use a boolean expression as index
# returns all elements greater than 0.2 in a new 1D array
# print(array[array > 0.2])

# methods for performing computations on arrays

# returns the sum of all items in the array
# print(np.sum(array))

# returns a new multi-D array with the floor of each item
# print(np.floor(array))

# returns a new multi-D array with the ceiling of each item
# print(np.ceil(array))

# returns a new multi-D array with the round of each item
# print(np.round(array))

# we can also perform arithmetic operations between arrays and numbers
first = np.array([1, 2, 3])
second = np.array([1, 2, 3])

# NumPy arrays supports all alrithmetic operations you're familiar with
# returns a new array by adding corresponding elements in both arrays
# print(first + second)

# returns a new array, and adds 2 to each individual item
# print(first + 2)

# a real world example, is when we have an array of numbers in inches
# and we want to convert it to centimeters
# dimensions_inch = np.array([1, 2, 3])

# convert the array to centimeters
# dimensions_cm = dimensions_inch * 2.54
# print(dimensions_cm)

# this is how it would be done in normal python code
dimensions_inch = [1, 2, 3]
dimensions_cm = [item * 2.54 for item in dimensions_inch]
print(dimensions_cm)
