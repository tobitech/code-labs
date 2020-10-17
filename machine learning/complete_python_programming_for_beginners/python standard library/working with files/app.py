from pathlib import Path
from time import ctime
import shutil

path = Path("ecommerce/__init__.py")
# path.exists()
# path.rename("init.txt")
# path.unlink()  # delete the file

# returns info about this file
# this info is an object with several attributes like
# st_size, st_ctime: creation time, st_mtime: modified time
# the time values are in seconds after epoch (the start of time on a computer)
print(path.stat())

# print human readable format of time
print(ctime(path.stat().st_ctime))  # Tue Nov 20 12:31:48 2018

# reading data fron a file
# returns the content of the file as a bytes object
# for representing binary data
path.read_bytes()

# return the content of a file as a string
path.read_text()

# this is simpler to use than the open() method that returns a file
# these ones take care of opening and closing a file

# you can write bytes or text to a file
path.write_bytes()
path.write_text("...")

# when it comes to copying a file, the Path object is not the ideal way to go
source = Path("ecommerce/__init__.py")
target = Path() / "__init__.py"

# to copy
target.write_text(source.read_text())  # this is a little bit tedious

# the better way is to use shutil
# this is cleaner and easier than using a Path object
shutil.copy(source, target)
