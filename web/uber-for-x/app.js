var http = require("http")
var express = require("express")
var consolidate = require("consolidate")
var _ = require("underscore")
var bodyParser = require("body-parser")

var routes = require("./routes") // File that contains our endpoints
var mongoClient = require("mongodb").MongoClient

var app = express()

app.use(bodyParser.urlencoded({
    extended: true
}))

// configure middleware for views here
app.use(bodyParser.json({limit: "5mb"}));

app.set("views", "views") // Set the folder-name where you serve the html page
app.use(express.static("./public")) // setting the folder name (public) where all the static files like css, jss, images etc are available.

app.set("view engine", "html")
app.engine("html", consolidate.underscore)

var server = http.Server(app)
var portNumber = 8000; // for localhost:8000

var io = require("socket.io")(server) // creating a new socket.io instance by passing the HTTP server object.

server.listen(portNumber, function () {
    console.log("Server listening at port " + portNumber)

    var url = "mongodb://tobitech:perfectTOBI9@ds044787.mlab.com:44787/uber-for-x"
    mongoClient.connect(url, function (err, db) {
        console.log("Connected to Database")

        app.get("/citizen.html", function (req, res) {
            res.render("citizen.html", {
                userId: req.query.userId
            })
        })

        app.get("/cop.html", function (req, res) {
            res.render("cop.html", {
                userId: req.query.userId
            })
        })

        io.on("connection", function(socket) {
            console.log("A user just connected")

            socket.on("join", function(data) {
                socket.join(data.userId)
                console.log("User joined room: " + data.userId)
            })

            routes.initialize(app, db, socket, io)
        })

    })

})