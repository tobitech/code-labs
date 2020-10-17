# class Mammal:
#     def eat(self):
#         print("eat")

#     def walk(self):
#         print("walk")


# class Fish:
#     def eat(self):
#         print("eat")

#     def swim(self):
#         print("swim")

# Using inheritance to solve the repition of common functions
# in some classes

class Animal:
    def __init__(self):
        self.age = 1

    def eat(self):
        print("eat")


# Animal is referred to as Parent or Base class
# Mammal is the child or subclass
class Mammal(Animal):  # `Mammal` inheriting from `Animal`
    def walk(self):
        print("walk")


class Fish(Animal):
    def swim(self):
        print("swim")


m = Mammal()
m.eat()  # Mammal object now has an eat() method
print(m.age)  # Attributes can be inherited as well
