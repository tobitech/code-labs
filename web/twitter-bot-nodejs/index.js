const Twit = require('twit');

const T = new Twit({
    consumer_key: process.env.TWITTER_API_KEY,
    consumer_secret: process.env.TWITTER_API_SECRET_KEY,
    access_token: process.env.TWITTER_ACCESS_TOKEN,
    access_token_secret: process.env.TWITTER_ACCESS_TOKEN_SECRET
});

// start a stream and track tweets
const stream = T.stream('statuses/filter', {track: '#JavaScript'});

// use this to log errors from the requests
function responseCallback(err, data, response) {
    console.log(err);
}

// event handler
stream.on('tweet', tweet => {
    // retweet
    T.post('statuses/retweet/:id', { id: tweet.id_str }, responseCallback);

    // like
    T.post('favorites/create', { id: tweet.id_str }, responseCallback);
});