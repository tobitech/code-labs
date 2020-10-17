class Animal:
    def __init__(self):
        self.age = 1

    def eat(self):
        print("eat")


# Animal is referred to as Parent or Base class
# Mammal is the child or subclass
class Mammal(Animal):
    def walk(self):
        print("walk")


class Fish(Animal):
    def swim(self):
        print("swim")


m = Mammal()

# `isinstance` tells us if an object is an instance of a given class
# print(isinstance(m, Mammal))  # returns True

# print(isinstance(m, Animal))  # returns True as well

# all classes inherits from `object` class
# print(isinstance(m, object))  # `m` is an instance of `object`

# built in function for creating an empty object
o = object()

# using the dot accessor you can see all the methods in this class,
# which is also all the methods that every class in python has
# o.__dict__
# m.__dict__


# `issubclass()` - check to see if a class derives from another class
print(issubclass(Mammal, Animal))  # returns True
print(issubclass(Mammal, object))  # also returns True
