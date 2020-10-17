import sqlite3
import json
from pathlib import Path

# movies = json.loads(Path("movies.json").read_text())
# print(movies)

# this will create a new database called `db` if it doesn't already exist
# this returns a connection object
# similar to file object should be closed when we are done with it
# so better approach is to use the `with statement`
# connection = sqlite3.connect("db.sqlite3")

# write data to the database
# with sqlite3.connect("db.sqlite3") as conn:
#     # we create a command for the connection
#     # to update data, create data, delete data etc.
#     # assuming we have a table called movies where we store our movies
#     # the `?` is a place holder for each value
#     command = "INSERT INTO movies VALUES(?, ?, ?)"
#     for movie in movies:
#         conn.execute(command, tuple(movie.values()))
#     # write the changes to the database
#     conn.commit()


# read data from the database
with sqlite3.connect("db.sqlite3") as conn:
    command = "SELECT * FROM Movies"
    # this returns a cursor.
    # a cursor is what we get when we read data from a database
    # a cursor is an iterable object
    cursor = conn.execute(command)
    # for row in cursor:
    #     # we get a tuple for values of rows in our database in each iteration
    #     print(row)
    # this will return all the rows in the table in one go
    movies = cursor.fetchall()
    # returns a list of rows: each row values as a tuple
    print(movies)  # we can only iterate over it once
