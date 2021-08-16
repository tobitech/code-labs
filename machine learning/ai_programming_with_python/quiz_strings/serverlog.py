# You’ll be provided with example data for a user, the time of their visit
# and the site they accessed. You should use the variables provided
# and the techniques you’ve learned to print a log message like this one
# (with the username, url, and timestamp replaced with values
# from the appropriate variables):

# Yogesh accessed the site http://petshop.com/pets/reptiles/pythons at 16:20.

username = "Kinari"
timestamp = "04:50"
url = "http://petshop.com/pets/mammals/cats"

# TODO: print a log message using the variables above.
# The message should have the same format as this one:
# "Yogesh accessed the site http://petshop.com/pets/reptiles/pythons at 16:20."
message = username + " " + "accessed the site " + url + " at " + timestamp
print(message)
