# This class encapsulates the commong functionalities/attribute of clothes
class Clothing:
    def __init__(self, color, size, style, price):
        self.color = color
        self.size = size
        self.style = style
        self.price = price

    def change_price(self, price):
        self.price = price

    def calculate_discount(self, discount):
        return self.price * (1 - discount)


class Shirt(Clothing):
    def __init__(self, color, size, style, price, long_or_short):
        Clothing.__init__(color, size, style, price)
        # we can add new attribute to the child class
        self.long_or_short = long_or_short

    # we can add new methods to this child class
    def double_price(self):
        self.price = 2*self.price


class Pants(Clothing):
    def __init__(self, color, size, style, price, waist):
        Clothing.__init__(color, size, style, price)
        self.waist = waist

    # we can override methods in the parent class
    def calculate_discount(self, discount):
        return self.price * (1 - discount / 2)
