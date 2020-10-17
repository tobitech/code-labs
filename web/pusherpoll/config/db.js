const mongoose = require("mongoose");

// Map global promises.
mongoose.Promise = global.Promise;

// mongoose connect
mongoose.connect("mongodb://tobitech:perfectTOBI9@ds046037.mlab.com:46037/pusher-poll")
    .then(() => {
        console.log("MongoDB connected");
    }).catch(err => console.log(err))