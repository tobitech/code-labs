# try:
#     age = int(input("Age: "))
#     xfactor = 10 / age
# except ValueError:
#     print("You didn't enter a valid age.")
# except ZeroDivisionError:
#     print("Age cannot be 0.")
# else:
#     print("No exceptions were thrown")


# let's say we want to show the same error message no matter the exception
try:
    age = int(input("Age: "))
    xfactor = 10 / age
except (ValueError, ZeroDivisionError):  # adding multiple exceptions
    print("You didn't enter a valid age.")
# any other except clause is ignored
# as soon as one previously listed is matched
# except ZeroDivisionError:
#     print("You didn't enter a valid age.")
else:
    print("No exceptions were thrown")
