from pathlib import Path

# a new path object with absolute path
# Path("C:\\Program Files\\Microsoft")  # backslash escaped

# using raw string
# Windows example
# Path(r"C:\Program Files\Microsoft")  # backslash doesn't need escaping
# Path("/usr/local/bin")  # macOS example

# # path object that represents the current folder
# Path()

# # relative path
# Path("ecommerce/__init__.py")

# # combine path objects
# Path() / Path("ecommerce")

# # combine path object with a string
# Path() / "ecommerce" / "__init__.py"

# # home directory of the current user
# Path.home()

path = Path("ecommerce/__init__.py")
path.exists()  # whether path exists
path.is_file()  # check to see if path represents a file
path.is_dir()  # check if path represents a directory

# extract individual component in the path
print(path.name)
print(path.stem)  # returns file name without the extension
print(path.suffix)  # get the path extension
print(path.parent)  # get the parent of the path

# create a new path object based no an existing path objec
# this file doesn't exist yet we are only representing its path
path = path.with_name("file.txt")

# path = path.with_suffix(".txt")  # used to change the extension of a file

print(path.absolute())
