import sys

# sys has an attribute `argv` short for argument variables
# print(sys.argv)

# if we run this on the terminal: python3 app.py -a -b -c
# we get this: ['app.py', '-a', '-b', '-c']
# that's 4 arguments.
# the first is always the name of our python program

if len(sys.argv) == 1:
    # the user hasn't supplied any arguments
    # the array always have at least one item, which is the name of our file
    print("USAGE: python3 app.py <password>")
else:
    password = sys.argv[1]
    print("Password", password)
