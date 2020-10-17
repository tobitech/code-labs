# def greet(name):  # the scope of `name` is the greet function
#     message = "a"  # the scope of this variable is the greet() function


# the variables are local to the function i.e. the don't exist anywhere else
# print(message)  # you get message not defined
# print(name)  # you get message not defined


# def send_email(name):
#     # the `name` anc `message` variables here
#     # are completely different from the ones above
#     message = "b"

message = "a"


def greet(name):
    # without using this global keyword,
    # you won't be able to change the value of `message`
    global message
    message = "b"


greet("Tobi")
print(message)  # you get `a`, without the `global message ` line
