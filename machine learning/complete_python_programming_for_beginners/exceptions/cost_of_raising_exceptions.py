from timeit import timeit

code1 = """
def calculate_xfactor(age):
    if age <= 0:
        raise ValueError("Age cannot be 0 or less.")
    return 10 / age


try:
    calculate_xfactor(-1)
except ValueError as error:
    # print(error)
    pass  # do nothing
"""

# returns time of execution of the piece of code after 10,000 repetitions
# print("first code=", timeit(code1, number=10000))  # first code= 0.213105785

# run after replace print() statement with `pass`
print("first code=", timeit(code1, number=10000))  # first code= 0.005543309


# alternate approach to raising an exception in our function
# here we want to return `None` object instead
code2 = """
def calculate_xfactor(age):
    if age <= 0:
        return None
    return 10 / age


xfactor = calculate_xfactor(-1)
if xfactor == None:
    pass
"""

# second code= 0.0018679009999999982
# almost 4 times faster
# the difference is glaring because we're running the code 10,000 times
# you won't see this difference if you run the code ones.
print("second code=", timeit(code2, number=10000))
