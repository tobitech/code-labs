# Basics of variables

students_count = 1000
print(students_count)

# floating point number
rating = 4.9

# boolean
is_public = False  # can also be True

# string
course_name = "Python Programming"
# you can also use single quotes
course_description = 'Introduction to Machine Learning'

# using triple quotes for long string
message = """
Hi John,

This is Mosh from codewithmosh.com

Blah blah blah
"""

# some string functions.
print(len(course_name))

# access a specific character in a string.
print(course_name[0])
print(course_name[-1])

# slice a string
print(course_name[0:3])  # get the first three characters in the string
print(course_name[0:])  # the last index would be the end index
print(course_name[:3])  # python would use 0 index by default
print(course_name[:])  # this returns a copy of the original string
