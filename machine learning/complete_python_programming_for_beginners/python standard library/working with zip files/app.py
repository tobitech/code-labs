from pathlib import Path
from zipfile import ZipFile

# this statement will create this file in our current folder
# `w` argument stands for write mode
# zip = ZipFile("files.zip", "w")

# we want to write all of the ecommerce folder to the zip file

# create a path for the ecommerce directory
# recursively find all the files in the directory
# and all its children with rglob()
# remember this returns a generator object
# for path in Path("ecommerce").rglob("*.*"):
#     zip.write(path)

# if anything goes wrong, this statement will not be called
# so we can either use a `try catch finally block` or `with statement`
# zip.close()

# re-write above code with `with statement`
# with ZipFile("files.zip", "w") as zip:
#     for path in Path("ecommerce").rglob("*.*"):
#         zip.write(path)

# now let's read the content of the zip file we just created
with ZipFile("files.zip") as zip:
    # returns a list of all the files in the zip file
    # print(zip.namelist())
    # get information from a file in the zip
    info = zip.getinfo("ecommerce/__init__.py")
    print(info.file_size)
    print(info.compress_size)
    # extract all the files from the zip file
    # you can optionally specify a differnt directory to extract to
    zip.extractall("extract")
