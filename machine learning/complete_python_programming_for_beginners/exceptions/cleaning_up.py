try:
    file = open("cleaning_up.py")
    age = int(input("Age: "))
    xfactor = 10 / age
    # this code won't run if there is an exception before we get here
    # file.close()
except (ValueError, ZeroDivisionError):
    print("You didn't enter a valid age.")
else:
    print("No exceptions were thrown")
finally:
    # this is where you should do clean up
    # this block will run whether an exception was thrown or not
    file.close()
