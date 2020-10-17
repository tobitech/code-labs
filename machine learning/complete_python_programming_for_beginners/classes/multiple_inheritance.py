class Employee:
    def greet(self):
        print("Employee greet")


class Person:
    def greet(self):
        print("Person greet")


class Manager(Employee, Person):
    # this is called mutliple inheritance
    pass


manager = Manager()

# we get `Employee greet` because we added it first
# so python checks the Manager class first for the method `greet()`
# if it doesn't find it check the first Base class
# if it finds, the lookup terminates there else if looks at the Person class
# if someone decides to change the order of these base classes
# our program will have a different behaviour
manager.greet()


# an example of a good usage of multiple inheritance
# these classes have different features

class Flyer:
    def fly(self):
        pass


class Swimmer:
    def swim(self):
        pass


class FlyingFish(Flyer, Swimmer):
    # we can combine the features in one class
    # i.e. a Fish that can fly and swim
    pass
