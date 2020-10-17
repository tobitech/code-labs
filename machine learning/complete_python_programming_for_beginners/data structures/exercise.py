from pprint import pprint

sentence = "This is a common interview question"

# my solution
# values = {}
# for char in sentence:
#     if char == " ":
#         continue
#     count = values.get(char, 0)
#     if count > 0:
#         values[char] += 1
#     else:
#         values[char] = count + 1

# print(values)

# Mosh's solution
char_frequency = {}
for char in sentence:
    if char in char_frequency:
        char_frequency[char] += 1
    else:
        char_frequency[char] = 1
# pprint(char_frequency, width=1)

char_frequency_sorted = sorted(
    char_frequency.items(),
    key=lambda kv: kv[1],
    reverse=True)

print(char_frequency_sorted[0])
