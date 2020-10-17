# say we want to save information about a user.
def save_user(**user):
    # print(user)  # user is of type dictionary based on the arguments
    print(user["age"])  # to access values in the dictionary.


# we can pass arbitrary keyword arguments
save_user(id=1, name="John", age=22)
