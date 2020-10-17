browsing_session = []
browsing_session.append(1)
browsing_session.append(2)
browsing_session.append(3)

print(browsing_session)

last = browsing_session.pop()
print(last)
print(browsing_session)

# `not []` for a list returns true if it's empty
if not browsing_session:  # check that browsing_session is not empty
    print("disable back button")

print("redirect", browsing_session[-1])
