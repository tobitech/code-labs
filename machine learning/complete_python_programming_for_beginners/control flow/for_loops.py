
# range generates numbers from 0 up to 3 but doesn't include the number 3
for number in range(3):
    print("Attempt", number + 1, (number + 1) * ".")


# range can take other forms of argument
for number in range(1, 4):  # start from 1 and finish before 4
    # we can remove + 1 becuase number starts from 1
    print("Attempt", number, number * ".")

# we can also pass a third argument as a step.
for number in range(1, 10, 2):
    print("Attempt", number, number * ".")
