high_income = True
good_credit = False

# if high_income and good_credit: # result is true if both conditions are true
#     print("Eligible")
# else:
#     print("Ineligible")

# result is true if at least one of the conditions is true
# if high_income or good_credit:
#     print("Eligible")
# else:
#     print("Not Eligible")

student = False

# this condition evaluates to false, because `not` inverses value of student
if not student:
    print("Eligible")
else:
    print("Not Eligible")

# a more complex scenerio
if (high_income or good_credit) and not student:
    print("eligible")
else:
    print("not eligible")
