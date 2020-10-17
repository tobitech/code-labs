import time

# returns the current time as a timestamp. Unix Epoch time
print(time.time())  # number of seconds after January 1, 1970

# this timestamp isn't human readable. we use it to perform calculations

# let's simulate sending an email to 10,000 recipient


def send_email():
    for i in range(10000):
        pass


start = time.time()  # get the current time
send_email()
end = time.time()  # get current time again at the end of the function
duration = end - start
print(duration)
