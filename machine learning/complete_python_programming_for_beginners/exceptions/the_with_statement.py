try:
    with open("cleaning_up.py") as file:
        print("File opened")
    age = int(input("Age: "))
    xfactor = 10 / age
except (ValueError, ZeroDivisionError):
    print("You didn't enter a valid age.")
else:
    print("No exceptions were thrown")

# not needed when using with statement
# the file is automatically closed (resources automatically released)
# that's because the file object supports context management protocol
# finally:
#     file.close()

# when you need to work with multiple external resources
try:
    # target is just a variable name
    # python will automatically release both these external resources
    with open("cleaning_up.py") as file, open("another_file.txt") as target:
        print("File opened")
    age = int(input("Age: "))
    xfactor = 10 / age
except (ValueError, ZeroDivisionError):
    print("You didn't enter a valid age.")
else:
    print("No exceptions were thrown")
