# this program is the same as the one we did in the while_loop lesson

# while True:
#     command = input("> ")
#     print("ECHO", command)
#     if command.lower() == "quit":
#         break

# Exercise: dispaly even numbers between 1 to 10
count = 0
for x in range(1, 10):
    if x % 2 == 0:
        print(x)
        count += 1
else:
    print(f"We have {count} even numbers")
