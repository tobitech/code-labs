class Animal:
    def __init__(self):
        self.age = 1

    def eat(self):
        print("eat")


class Mammal(Animal):
    def __init__(self):
        # we use this function to execute the constructor in our base class
        # this can also be called at the end of this constructor
        super().__init__()
        self.weight = 2

    def walk(self):
        print("walk")


m = Mammal()

# without calling super().__init__() in Mammal's constructor,
# returns AttributeError: Mammal object has no attribute age
# becuase the constructor in Animal wasn't executed
# when we created an instance of Mammal
# the constructor in the Mammal class
# replaced the constructor in the base class
# this is what we call method overriding
print(m.age)

print(m.weight)
