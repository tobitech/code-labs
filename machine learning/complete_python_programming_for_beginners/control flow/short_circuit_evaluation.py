high_income = True
good_credit = False
student = True

# evaluation stops as soon as a False is detected.
if high_income and good_credit and not student:
    print("eligible")

# evaluation stops as soon as a True is detected.
if high_income or good_credit or not student:
    print("eligible")
