from abc import ABC, abstractmethod

# let's modify what we had from the last lesson


class TextBox():
    def draw(self):
        print("TextBox")


class DropDownList():
    def draw(self):
        print("DropDownList")

# controls parameter is purely a label (name)
# the type is not specified.
# we can pass any kind of object to the draw function
# as long as that object is iterable, python will be happy
# as part of that token, each object in the list should have a draw method
# this is what we call `duck typing`
# python is a dynamically typed language and doesn't check the type of objects
# it only looks for the existence of certain methods in an object


def draw(controls):
    for control in controls:
        # in this line python looks for the draw() method
        # it assume that if it has a draw() method it is a UIControl
        # if it walks like a duck, or quacks like a duck, then it is a duck
        control.draw()
