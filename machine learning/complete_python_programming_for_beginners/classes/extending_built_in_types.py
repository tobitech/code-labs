class Text(str):
    # remember that self represents the current object
    # which in this case is an instance of the `str` class
    def duplicate(self):
        return self + self


# text = Text("Python")
# text.lower()  # our Text object has all the methods of a python string
# print(text.duplicate())  # returns PythonPython


class TrackableList(list):
    # we are extending the append method of the list class
    def append(self, object):
        print("Append called")
        super().append(object)


list = TrackableList()
list.append("1")
