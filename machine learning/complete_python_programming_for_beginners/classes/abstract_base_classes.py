from abc import ABC, abstractmethod


class InvalidOperationError(Exception):
    pass


class Stream(ABC):
    def __init__(self):
        self.opened = False

    def open(self):
        if self.opened:
            raise InvalidOperationError("Stream is already opened")
        self.opened = True

    def close(self):
        if not self.opened:
            raise InvalidOperationError("Stream is already closed.")
        self.opened = False

    @abstractmethod  # decorator used to signify that it's an abstract method
    def read(self):
        pass  # this method has no implementation


class FileStream(Stream):
    def read(self):
        print("reading data from a file")


class NetworkStream(Stream):
    def read(self):
        print("reading data from a network")


class MemoryStream(Stream):
    # We have to implement the read method to make it a concrete class
    def read(self):
        print("Reading data from a memory stream")


# we can't instantiate an abstract class
# we cannot make an instance of them
# stream = Stream()  # returns TypeError: can't instantiate abstract class
# stream.open()

# if a class derives from an abstract class
# it has to implement the abstract method,
# otherwise that class will also be considered abstract
# stream = MemoryStream()  # returns TypeError
# stream.open()

stream = MemoryStream()  # MemoryStream is now a concrete method
stream.open()
