def multiply(*numbers):  # numbers is a tuple
    total = 1
    for number in numbers:  # we can iterate over it.
        total *= number
    return total


print(multiply(2, 3, 5, 6))
