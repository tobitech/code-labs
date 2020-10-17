from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.image import MIMEImage
from pathlib import Path
import smtplib

message = MIMEMultipart()

message["from"] = "Tobi Omotayo"
message["to"] = "tobitech@ymail.com"
message["subject"] = "This is a test"


message.attach(MIMEText("Body of the message"))
message.attach(MIMEImage(Path("new_profile.jpg").read_bytes()))

with smtplib.SMTP(host="smtp.gmail.com", port=587) as smtp:
    smtp.ehlo()
    smtp.starttls()
    smtp.login("oluwatobi.omotayo@bankwithmint.com", "perfectTOBI9")
    smtp.send_message(message)
    print("Sent...")
