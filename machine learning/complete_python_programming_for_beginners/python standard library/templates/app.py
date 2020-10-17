from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.image import MIMEImage
from pathlib import Path

# we use the `Template` class to replace the parameters in a template string
from string import Template
import smtplib

template = Template(Path("template.html").read_text())
# with substitute, we can replace parameters dynamically
# template.substitute()

message = MIMEMultipart()
message["from"] = "Tobi Omotayo"
message["to"] = "tobitech@ymail.com"
message["subject"] = "This is a test"

# we can pass in a dictionary or keyword argument
# if you have a dictionary of all parameters you want to replace dynamically
# body = template.substitute({"name": "John"})
body = template.substitute(name="John")

message.attach(MIMEText(body, "html"))
message.attach(MIMEImage(Path("new_profile.jpg").read_bytes()))

with smtplib.SMTP(host="smtp.gmail.com", port=587) as smtp:
    smtp.ehlo()
    smtp.starttls()
    smtp.login("oluwatobi.omotayo@bankwithmint.com", "perfectTOBI9")
    smtp.send_message(message)
    print("Sent...")
