# print("Sales initialized", __name__)


def calc_tax():
    pass


def calc_shipping():
    pass


# with this piece of code we can make this file usable
# as well as a resuable module that we can import into another module
# if you run this code, the code block would be executed
# but if you import this module elsewhere,
# the __name__ would no longer be __main__
# in our case it will be `ecommerce.shopping.sales`
if __name__ == "__main__":
    print("Sales started")
    calc_tax()
