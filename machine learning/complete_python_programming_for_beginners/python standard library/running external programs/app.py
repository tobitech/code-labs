import subprocess

# some helper methods in subprocess module
# these ones have been around for long and are now considered legacy
# subprocess.call()
# subprocess.check_call()
# subprocess.check_output()
# subprocess.Popen()  # stands for process open

# there are newer approaches

# creates an instance of the Popen class
# this takes a list,
# if you want to supply arguments,
# you pass them as items in the list
# completed = subprocess.run(["ls", "-l"])
# print(type(completed))  # returns `<class 'subprocess.CompletedProcess'>`

# arguments: list of commands we executed ['ls', '-l']
# print("args", completed.args)
# return code: 0 mean successful any non-zero value indicates an error
# print("returncode", completed.returncode)
# print("stderr", completed.stderr)  # standard error: None
# standard output: None because we're not capturig the output
# it's automatically printed on the terminal window
# print("stdout", completed.stdout)


# sometimes we want to read the output of a program
# and perhaps write it to a file
# run() has some keyword arguments and all of them have a default value

# if capture_output is True, the output won't be printed to the terminal
# but will be captured in the stdout attribute
# completed = subprocess.run(
#     ["ls", "-l"],
#     capture_output=True,
#     text=True)

# this returns stdout b'total 8\n-rw-r--r--
# 1 oluwatobiomotayo  staff  1326 Jun 19 16:25 app.py\n'
# the `b` prefix represents a binary object
# the `b` prefix won't be there if we supply text=True parameter
# print("stdout", completed.stdout)


# Running other scripts
# the other python script is executed as a child process,
# so it's going to be in a completely different memory space
# different from importing the script and executing it inside here
# so these two scripts will be in two separate processes
# and will not share the same variables
# completed = subprocess.run(
#     ["python3", "other.py"],
#     capture_output=True,
#     text="True")


# let's look at a case where returncode isn't `0`
# this `false` program always exits with `1` as its return code
# which is an error
# it's our job to check for that and handle it.
# another approach is to pass another argument check=True
# when we do that this method will automatically raise an exception
# returns CalledProcessError exception
# so we can then wrap the code in a try-block

try:
    completed = subprocess.run(
        ["false"],
        capture_output=True,
        text="True", check=True)

    print("args", completed.args)
    print("returncode", completed.returncode)
    print("stderr", completed.stderr)
    print("stdout", completed.stdout)
    # not needed if we pass check=True argument
    # if completed.returncode != 0:
    # print(completed.stderr)
except subprocess.CalledProcessError as ex:
    print(ex)
