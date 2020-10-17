from datetime import datetime, timedelta

dt1 = datetime(2018, 1, 1)
dt2 = datetime.now()

# when we substract these two times we get a timedelta object
duration = dt2 - dt1
print(duration)  # returns 900 days, 14:12:13.273545

# the timedelta object returned has some interesting attributes
print("days", duration.days)
print("seconds", duration.seconds)  # the remaining seconds after the days

# total duration represented as seconds
print("total_seconds", duration.total_seconds())

# we can add a timedelta object to a datetime object
# dt1 + timedelta(1)  # add 1 day to the datetime object

# if anyone else is reading the code,
# they might not know what the 1 stands for
# so better to use keyword argument for clarity
dt1 + timedelta(days=1, seconds=1000)
