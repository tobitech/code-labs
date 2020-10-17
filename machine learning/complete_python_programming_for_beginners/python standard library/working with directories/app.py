from pathlib import Path

path = Path("ecommerce")  # this represents a directory
# path.exists()
# path.mkdir()  # to create the directory on disk
# path.rmdir()  # remove directory from disk
# path.rename("ecommerce2")  # give it a new name

# get the list of files and directories in this path
print(path.iterdir())

# iterate over the generator
# for p in path.iterdir():
#     print(p)

# if you're working with a directory that doesn't have a million files in it
# you can convert this generator object to a list using a list expression
# paths = [p for p in path.iterdir()]

# add a filtering condition to the expression
paths = [p for p in path.iterdir() if p.is_dir()]
print(paths)  # returns a list of `PosixPath` objects

# iterdir() has some limitations in which case we can use  `glob()`
path.glob("*")  # search all files
path.glob("*.py")  # all files with .py extension

# this returns a generator as well
py_files = [p for p in path.glob("*.py")]
print(py_files)

# to search recursively we need to set a different kind of pattern
py_files = [p for p in path.glob("**/*.py")]

# or use `rglob()` method - recursive glob
# we can still maintain the pattern in that case

# this returns all the .py files and all its children
py_files = [p for p in path.rglob("*.py")]
