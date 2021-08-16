mon_sales = "121"
tues_sales = "105"
wed_sales = "110"
thurs_sales = "98"
fri_sales = "95"

# TODO: Print a string with this format: This week's total sales: xxx
# You will probably need to write some lines of code before the print statement.
# total_sales = ((mon_sales) + (tues_sales) +
#    (wed_sales) + (thurs_sales) + (fri_sales))
# print("This week\'s total sales: + (total_sales)")

total_sales = int(mon_sales) + int(tues_sales) + \
    int(wed_sales) + int(thurs_sales) + int(fri_sales)

print(f"This week\'s total sales: {total_sales}")
