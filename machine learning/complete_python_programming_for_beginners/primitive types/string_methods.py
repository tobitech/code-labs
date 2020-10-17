course = "  python programming   "
# len() - this function isn't limited to strings

# convert a string to upper case
print(course.upper())

# the methods you call here return a new string
# so the original string is not affected

# make every word in the string lower case.
print(course.lower())

# capitalized the first letter of every word
print(course.title())

# remove whitespace from a particular input: from beginning and end
# useful especially when we receive inputs from a user
print(course.strip())
print(course.lstrip())  # remove leading whitespace
print(course.rstrip())  # remove trailing whitespace

# get index of a character or a sequence of character in your string
print(course.find("pro"))

# returns -1 since the substring isn't found in the orignal string
print(course.find("Pro"))

# replace a character or sequence of characters with something else.
print(course.replace("p", "j"))

# check if a character or a sequence of characters exists in your string
# use the `in` operator
print("pro" in course)  # returns a boolean

# check if string does not contain character or sequence of characters
print("swift" not in course)
