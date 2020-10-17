x = input("x: ")  # in built function to get input from the user
# y = x + 1

# print(type(x))  # get the type of an object

# some in built type conversion functions
# int(x) # convert to integer
# float(x) # convert to float
# bool(x) # convert to bool
# str(x) # convert to string

y = int(x) + 1
print(f"x: {x}, y:{y}")


# Falsy values in python
# "" - empty string, interpreted as a boolean false
# 0 - number zero
# None - an object which represents the absence of a value
# whenever we use these falsy values in a boolean context, we wil get false.
# anything else will be true
