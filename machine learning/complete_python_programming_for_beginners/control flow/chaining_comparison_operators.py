# say we want to implement a rule that an age should be between 18 and 65
age = 22

if age >= 18 and age < 65:
    print("eligible")

# the above can also be written as
if 18 <= age < 65:  # this is called chaining comparison operators
    print("eligible")
