class Animal:
    def eat(self):
        print("eat")


class Bird(Animal):
    def fly(self):
        print("fly")


class Chicken(Bird):
    # but a Chicken cannot fly
    # try to limit your inheritance to 1 or 2 levels
    pass
