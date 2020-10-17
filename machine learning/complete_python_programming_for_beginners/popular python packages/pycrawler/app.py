import requests
from bs4 import BeautifulSoup

response = requests.get("https://stackoverflow.com/questions")
# response.text  # returns the HTML content of this webpage

# soup mirrors the structure of our HTML document
# so we can easily navigate this HTML and find various elements
soup = BeautifulSoup(response.text, "html.parser")

questions = soup.select(".question-summary")

# print(type(questions[0]))  # each question is a type of the `Tag` class
# print(questions[0].attrs)

# if this attribute doesn't exist we will get an exception
# print(questions[0]["id"])  # we can get each attribute by its key

# safer way is to use the get() method
# print(questions[0].get("id", 0))

# let's get the title for each question
# Tag object also has a select() method like its super object
# print(questions[0].select(".question-hyperlink"))

# since we don't need a list, we can use select_one() to return one object.
# this is useful in cases where we know we're dealing with one single element
# print(questions[0].select_one(".question-hyperlink"))

# let's get the content of our tag
# print(questions[0].select_one(".question-hyperlink").getText())

# iterate over questions and get the title of each
for question in questions:
    print(question.select_one(".question-hyperlink").getText())
    print(question.select_one(".vote-count-post").getText())
