'use strict';
var path = require('path');
var express = require('express');
var router = express.Router();
var TournamentMaster = require(path.join(__dirname, '../models/TournamentMaster.js'));
var Tournament = require(path.join(__dirname, '../models/Tournament.js'));

router.get('/', (req, res, next) => {
    if (typeof req.query === "undefined" || typeof req.query.api_key === "undefined") {
        res.sendStatus(400).end();
        return next();
    }
    TournamentMaster.find({
        api_key: req.query.api_key
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
});

router.get('/:id', (req, res, next) => {

});


/*
 * @param api_key
 * @param name Tournament Name
 * @param description Tournament description
 * @param tournament_type Tournament(Single,Two) stages
 * @param [participants] Tournament participants
 * @param  group_stage_type First stage tournament type "not requierd"
 * @param final_stage_type Second stage tournament typre "required"
 */
router.post('/', (req, res, next) => {
    console.log(req.body);
    if (typeof req.body === "undefined" || typeof req.body.api_key === "undefined" || typeof req.body.name === "undefined" || typeof req.body.tournament_type === "undefined" || typeof req.body.group_stage_type === "undefined" || typeof req.body.description === "undefined" || typeof req.body.participants === "undefined") {
        res.sendStatus(400).end();
        return next();
    }
    if (req.body.tournament_type === "two_stage" && typeof req.body.group_stage_type === "undefined") {
        res.sendStatus(400).end();

        return next();
    }
    res.json({
        name:req.body.name,
        description:req.body.description,
        tournament_type:req.body.tournament_type,
        group_stage_type:req.body.group_stage_type,
        final_stage_type:req.body.final_stage_type || "Nothing",
        participants:req.body.participants
    });
});

router.delete('/:id', (req, res, next) => {

});
module.exports = router;
