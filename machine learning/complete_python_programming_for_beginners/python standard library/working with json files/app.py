import json
from pathlib import Path

# let's create a list of movie objects
# movies = [
#     {"id": 1, "title": "Terminator", "year": 1989},
#     {"id": 2, "title": "Kindergaten Cop", "year": 1990}
# ]

# get a string that includes the movie data formatted as json
# data = json.dumps(movies)
# print(data)

# we can write the data into a file
# Path("movies.json").write_text(data)

# Let's say we want to read from a json file
data = Path("movies.json").read_text()

# parse this string into a list of objects
movies = json.loads(data)  # this returns a list of dictionaries
# print(movies)
# print(movies[0])  # get the first item in the list
print(movies[0]["title"])
