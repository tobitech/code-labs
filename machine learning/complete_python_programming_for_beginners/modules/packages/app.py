# import ecommerce.sales

# ecommerce.sales.calc_tax()

# better approach is to use the from statement
# so that we don't have to alway prefix the use of objects
# with the package name

# from ecommerce.sales import calc_tax

# calc_tax()

from ecommerce import sales

sales.calc_tax()
