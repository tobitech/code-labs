from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.image import MIMEImage
from pathlib import Path
import smtplib

# let's create a MIMEMultipart object
message = MIMEMultipart()

# these are headers supported by MIMEMultipart
message["from"] = "Tobi Omotayo"
message["to"] = "tobitech@ymail.com"
message["subject"] = "This is a test"

# there is no body header, so we need to attach it
# attach() takes a payload that can be text, image
# or other content supported by the mime protocol

# html subtype
# message.attach(MIMEText("<p>Body of the message</p>", "html"))

message.attach(MIMEText("Body of the message", "plain"))  # plain subtype

# attaching an image
message.attach(MIMEImage(Path("new_profile.jpg").read_bytes()))

# now we need to send our message through an SMTP server
# these values depend on the SMTP server we use
# this returns an smtp object
# we need to close it when we're done so preferably we use `with statement`
with smtplib.SMTP(host="smtp.gmail.com", port=587) as smtp:
    # first we need to send a greeting to the smtp server
    smtp.ehlo()
    # this puts the SMTP connection in TLS mode: Transport Layer Security
    # with this all our commands sent to SMTP will be encrypted
    smtp.starttls()
    # next we login
    smtp.login("oluwatobi.omotayo@bankwithmint.com", "perfectTOBI9")
    smtp.send_message(message)
    print("Sent...")
