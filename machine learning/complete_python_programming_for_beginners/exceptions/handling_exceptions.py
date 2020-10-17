# we know from last lesson that this code throws an error
# if the user inputs a non-numeric value
# age = int(input("Age: "))

# let's handle the error
# try:
#     age = int(input("Age: "))
# except ValueError:
#     print("You didn't enter a valid age.")
# else:
#     # will run if the code in try block didn't throw an exception
#     print("No exceptions were thrown")
# print("Execution continues")

# add an expression identify to where you're catching the exception
# the ex variable gives us more info about the exception
try:
    age = int(input("Age: "))
except ValueError as ex:
    print("You didn't enter a valid age.")
    print(ex)
    print(type(ex))
else:
    # will run if the code in try block didn't throw an exception
    print("No exceptions were thrown")
print("Execution continues")
