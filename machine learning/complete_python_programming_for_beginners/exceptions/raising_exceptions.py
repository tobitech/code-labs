def calculate_xfactor(age):
    if age <= 0:
        # raising exceptions like this is not advisable
        # this is for demonstration purposes
        # as we will see in next lesson, raising exception is costly
        raise ValueError("Age cannot be 0 or less.")
    return 10 / age


# calculate_xfactor(-1)  # throws an unhandled exception

try:
    calculate_xfactor(-1)
except ValueError as error:
    print(error)
