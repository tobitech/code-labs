from twilio.rest import Client

account_sid = "ACe55b8f17556e597cd0e5e26c662eb413"
auth_token = "de1f3fd97ad0efda3669bd1bd3cec44a"

client = Client(account_sid, auth_token)

# cost $0.10 (10 cents) per text message
call = client.messages.create(
    to="+2347069215481",
    from_="+13103410320",
    body="This is a message from PyText"
)

print(call)
