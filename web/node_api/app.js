const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser')

const app = express();

if (process.env.ENV === 'Test') {
  console.log('This is a test');
  const db = mongoose.connect('mongodb://tobitech:perfectTOBI9@ds040309.mlab.com:40309/book_api_test', {
  useNewUrlParser: true
}, (err) => {
  if (err) {
    console.log(err.message);
  } else {
    console.log('Connected to database...')
  }
});
} else {
  console.log('This is for real')
  const db = mongoose.connect('mongodb://tobitech:perfectTOBI9@ds040309.mlab.com:40309/book_api', {
  useNewUrlParser: true
}, (err) => {
  if (err) {
    console.log(err.message);
  } else {
    console.log('Connected to database...')
  }
});
}

/*
const db = mongoose.connect('mongodb://tobitech:perfectTOBI9@ds040309.mlab.com:40309/book_api', {
  useNewUrlParser: true
}, (err) => {
  if (err) {
    console.log(err.message);
  } else {
    console.log('Connected to database...')
  }
});
*/

const port = process.env.PORT || 3000;
const Book = require('./models/bookModel');
const bookRouter = require('./routes/bookRouter')(Book);

app.use(bodyParser.urlencoded({extended: true}));
app.use(bodyParser.json());

app.use('/api', bookRouter);

app.get('/', (req, res) => {
  res.send('Welcome to my Nodemon API!');
});

app.server = app.listen(port, () => {
  console.log(`Running on port: ${port}`);
});


module.exports = app;