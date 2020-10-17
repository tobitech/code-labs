const express = require('express');
const graphqlHTTP = require('express-graphql');
const schema = require('./schema/schema');
const mongoose = require('mongoose');
const cors = require('cors');

const app = express();

// allow cross origin request
app.use(cors());

mongoose.connect('mongodb://tobitech:perfectTOBI9@ds135818.mlab.com:35818/gql-ninja', {
    useUnifiedTopology: true,
    useNewUrlParser: true
});
mongoose.connection.once('open', () => {
    console.log('Connected to database');
});

app.use('/graphql', graphqlHTTP({
    schema,
    graphiql: true
}));

app.listen(4000, ()=> {
    console.log('Now listening for requests on port 4000');
});