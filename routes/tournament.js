'use strict';
var path = require('path');
var express = require('express');
var router = express.Router();
var TournamentMaster = require(path.join(__dirname, '../models/TournamentMaster.js'));
var Tournament = require(path.join(__dirname, '../models/Tournament.js'));

router.get('/', (req, res, next) => {
    if (typeof req.body === "undefined" || typeof req.body.api_key === "undefined") {
        res.sendStatus(400).end();
    } else {
        TournamentMaster.find({
            api_key: req.body.api_key
        }, (err, tournaments) => {
            if (err) {
                res.sendStatus(500).end();
            } else {
                res.json({
                    valid: true,
                    tournaments: tournaments
                });
            }
        });
    }
});

router.get('/:id', (req, res, next) => {

});

router.post('/', (req, res, next) => {

});

router.delete('/:id', (req, res, next) => {

});
module.exports = router;
