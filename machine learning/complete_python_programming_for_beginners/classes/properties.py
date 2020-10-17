class Product():
    def __init__(self, price):
        self.price = price


# python interpreter will execute this without any problem
product = Product(-50)

# how can we prevent this and ensure that our products
#  don't have a negative price?
# one simple way to solve this is to make `price` private
# and define two methods to get and set our price

# this approach is ugly and considered unpythonic


class Product():
    def __init__(self, price):
        self.set_price(price)

    def get_price(self):
        return self.__price

    def set_price(self, value):
        if value < 0:
            raise ValueError("Price cannot be negative.")
        self.__price = value


# product = Product(-50)  # throws a ValueError

# this kind of code above is what a Java programmer learning python writes 😂
# this is where Properties come in


class Product():
    def __init__(self, price):
        self.set_price(price)

    # we had underscores to make these methods private
    def __get_price(self):
        return self.__price

    def __set_price(self, value):
        if value < 0:
            raise ValueError("Price cannot be negative.")
        self.__price = value

    # this will create a property object that takes get and set functions
    # note we are not calling the functions but passing a reference to them
    # that property object willl use get_price
    # to read the value of the price attribute
    price = property(__get_price, __set_price)


product = Product(10)

# # we can also set the price
product.price = -1  # this returns an exception though

print(product.price)  # we can read the price attribute with this property

# instead of explicitly calling the property function in the solution above
# we can apply the `@property` decorator to get_price method
# and apply `@price.setter` decorator to the set_price method
# the price part of it is the name of our property


class Product():
    def __init__(self, price):
        # we can now use our property like a regular attribute
        self.price = price

    @property
    def price(self):
        return self.__price

    # without this setter, our property becomes read only
    # @price.setter
    # def price(self, value):
    #     if value < 0:
    #         raise ValueError("Price cannot be negative.")
    #     self.__price = value


product = Product(-10)
# returns AttributeError: can't set attribute
# when we don't have a setter for our property
product.price = 2
print(product.price)
