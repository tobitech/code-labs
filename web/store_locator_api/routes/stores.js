const express = require('express');
const { getStores, addStore } = require('../controllers/stores')

const router = express.Router();

// Routes
router.route('/')
    .get(getStores)
    .post(addStore);

module.exports = router;
