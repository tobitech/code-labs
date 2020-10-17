# successful = True

# jump out of a loop with break
# for number in range(3):
#     print("Attempt")
#     if successful:
#         print("Sucessful")
#         break

successful = False

for number in range(3):
    print("Attempt")
    if successful:
        print("Sucessful")
        break
else:  # this will run if the loop completes without an early termination
    print("Attempted 3 times and failed")
