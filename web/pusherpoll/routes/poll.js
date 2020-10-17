const express = require("express");
const router = express.Router();
const mongoose = require("mongoose");
const Vote = require("../models/Vote");

const Pusher = require("pusher");

var pusher = new Pusher({
    appId: '747534',
    key: '7635980a0adb5a1b95b2',
    secret: '0054aba1e65c4d9fa738',
    cluster: 'eu',
    encrypted: true
});

router.get("/", (req, res) => {
    Vote.find().then(votes =>
        res.json({
            success: true,
            votes: votes
        }));
});

router.post("/", (req, res) => {
    const newVote = {
        os: req.body.os,
        points: 1
    }

    new Vote(newVote).save()
    .then(vote => {
        pusher.trigger('os-poll', 'os-vote', {
            points: parseInt(vote.points),
            os: vote.os
        });
    }).catch(err => console.log(err));

    return res.json({
        success: true,
        message: "Thank you for voting."
    })
})

module.exports = router;