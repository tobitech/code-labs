from selenium import webdriver

browser = webdriver.Chrome()
browser.get("https://github.com")

signin_link = browser.find_element_by_link_text("Sign in")
signin_link.click()

username_box = browser.find_element_by_id("login_field")
# simulate user typing into a textbox
username_box.send_keys("tobitech@ymail.com")

password_box = browser.find_element_by_id("password")
password_box.send_keys("perfectTOBI9")

password_box.submit()

# page_source returns the HTML content of the webpage
# use assert statement to verify a condition
# in this case that the username is contained in the page's HTML source
assert "tobitech" in browser.page_source

# a more specifig assertion
profile_link = browser.find_element_by_class_name("user-profile-link")
link_label = profile_link.get_attribute("innerHTML")
assert "tobitech" in link_label

# close the browser otherwise you end up with so many opend browser windows
browser.quit()
