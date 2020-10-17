# import datetime
from datetime import datetime
import time

# this way of creating a datetime
# takes a year, month and day
# optionally we can pass the hour, minute and seconds as well
# this returns a datetime object
# dt = datetime.datetime(2020, 6, 19)

# # let's write the above code in a better way
dt1 = datetime(2020, 6, 19)
dt2 = datetime.now()  # returns the current datetime

# we use strptime() for parsing or converting a datetime string
# it takes a format method in which we pass in directives
# %Y (uppercase) - represents a 4-digit year
# %m (lowercase) - represents a 2-digit month
# %d (lowercase) - represents a 2-digit day
dt = datetime.strptime("2020/06/19", "%Y/%m/%d")

# convert a timestamp to a datetime object
dt = datetime.fromtimestamp(time.time())
# print(dt)

print(f"{dt.year}/{dt.month}")

# we also have a method for formating datetimes
# strftime is the opposite of strptime
# i.e. for converting a datetime object into a string
print(dt.strftime("%Y/%m"))

# we can compare datetime objects
print(dt2 > dt1)
