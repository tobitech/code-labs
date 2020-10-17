x = 10
y = 11

# let's swap the two variables above

# z = x  # store the value of `x` in a third variable
# x = y  # copy the value of `y` to `x`
# y = z  # override `y` with the initial value of `x` we retained with `z`

# cleaner way to do it in python
# define a tuple `(y, x)` or without parenthesis `y,x`
# then unpack it by overriding values of `x` and `y`
x, y = y, x

print("x:", x)
print("y:", y)
