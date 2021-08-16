# def fizz_buzz(number):
#     if (number % 3 == 0) and (number % 5 == 0):
#         return "FizzBuzz"
#     if number % 3 == 0:
#         return "Fizz"
#     if number % 5 == 0:
#         return "Buzz"
#     return number

# print(fizz_buzz(20))

def is_multiple_of_3_or_5(number: int) -> bool:
    """This returns whether a number is multiple of 3 or 5

    Args:
        The only parameter

    Returns:
        The return value. True for success, False otherwise
    """
    if (number % 3 == 0) or (number % 5 == 0):
        return True
    return False


# print(is_multiple_of_3_or_5(20))


def sum_of_multiples_of_3_or_5(number: int) -> int:
    """This calculates the sum of all multiples of 3 or 5 below a number

    Args:
        number (int): First parameter

    Returns:
        int: Returns the sum of the multiples
    """
    sum = 0
    for num in range(number):
        if is_multiple_of_3_or_5(num):
            sum += num
    return sum


print(sum_of_multiples_of_3_or_5(1000))
