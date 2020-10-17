import csv

# with open("data.csv", "w") as file:
#     # writer takes a file, that's why we can't use the Path module here
#     # with writer we can write tabular data to our file
#     writer = csv.writer(file)
#     # takes a list of values
#     # let's write the headings of the rows
#     writer.writerow(["transaction_id", "product_id", "price"])
#     # let's write the first row
#     writer.writerow([1000, 1, 5])
#     writer.writerow([1001, 2, 15])

# Now let's read from a CSV file
with open("data.csv") as file:
    reader = csv.reader(file)
    # get all the data in the csv file and convert it to a list object
    # print(list(reader))  # returns a list of lists
    # we can iterate over the reader
    # we cannot iterate this reader twice
    # so comment out line 18
    for row in reader:
        print(row)
