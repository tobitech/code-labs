import requests
import config

url = "https://api.yelp.com/v3/businesses/search"
headers = {
    "Authorization": "Bearer " + config.api_key
}
params = {
    "term": "Barber",
    "location": "NYC"
}
response = requests.get(url, headers=headers, params=params)

# text returns the response as plain text
# print(response.text)

# gets the resonse as JSON
businesses = response.json()["businesses"]
# print(businesses)  # returns a list of dictionaries

# we can loop over the list and print each business name
# for business in businesses:
#     print(business["name"])

# this list comprehension will return the list of these businesses
# then we add a filter for rating greater than 4.5, and add that to the list
names = [business["name"]
         for business in businesses if business["rating"] > 4.5]
print(names)  # returns the highest rated barbers in New York City 😀
