'use strict';
var path = require('path'),
    express = require('express'),
    Duel = require('duel'),
    GroupStage = require('groupstage');
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
    //Check all information is available
    if (typeof req.body === "undefined" || typeof req.body.api_key === "undefined" || typeof req.body.name === "undefined" || typeof req.body.tournament_type === "undefined" || typeof req.body.group_stage_type === "undefined" || typeof req.body.description === "undefined" || typeof req.body.participants === "undefined" || typeof req.body.game === "undefined") {
        res.sendStatus(400).end();
        return next();
    }
    if (req.body.tournament_type === "two_stage" && typeof req.body.group_stage_type === "undefined") {
        res.sendStatus(400).end();
        return next();
    }

    if (req.body.tournament_type === "single_stage") {
        createSingleStage(req.body, res);
    } else {
        createDoubleStage(req.body, res);
    }

});

function createDoubleStage(data, res) {
    var numParticipants = data.participants.length;
    var numParticipants = data.participants.length;
    let groupStage;
    if (data.group_stage_type === "single_elimination") {
        groupStage = new Duel(numParticipants);
    } else if (data.group_stage_type === "double_elimination") {
        groupStage = new Duel(numParticipants, { last: 2 });
    } else { //Round Robin
        groupStage = GroupStage(numParticipants);
    }
    let finalStage;
    if (data.final_stage_type === "single_elimination") {
        finalStage = new Duel(numParticipants);
    } else if (data.final_stage_type === "double_elimination") {
        finalStage = new Duel(numParticipants, { last: 2 });
    } else { //Round Robin
        finalStage = GroupStage(numParticipants);
    }
    let newTournamentMaster = new TournamentMaster({
        name: data.name,
        description: data.description,
        api_key: data.api_key,
        game: data.game,
        tournament_type: data.tournament_type
    });
    let groupStageTournament = new Tournament({
        parent_id: newTournamentMaster._id,
        tournament_type: data.group_stage_type,
        participants: data.participants,
        api_key:data.api_key,
        data: {
            num_players: numParticipants,
            options: {},
            state: groupStage.state.slice(),
            metadata: groupStage.metadata()
        }
    });
    let finalStageTournament = new Tournament({
        parent_id: newTournamentMaster._id,
        tournament_type: data.final_stage_type,
        participants: [],
        api_key:data.api_key,
        data: {
            num_players: numParticipants,
            options: {},
            state: groupStage.state.slice(),
            metadata: groupStage.metadata()
        }
    });
    newTournamentMaster.group_stage_id = groupStageTournament._id;
    newTournamentMaster.final_stage_id = finalStageTournament._id;
    newTournamentMaster.save((err, tournament) => {
        if (err) {
            res.sendStatus(500).end();
        } else {
            groupStageTournament.save((err, groupStage) => {
                if (err) {
                    res.sendStatus(500).end();
                } else {
                    finalStageTournament.save((err)=>{
                        if (err) {
                            res.sendStatus(500).end();
                        } else {
                                res.json({
                                valid: true,
                                created: true
                            });
                        }
                    });
                }
            });
        }
    });
}

function createSingleStage(data, res) {
    var numParticipants = data.participants.length;
    let groupStage;
    if (data.group_stage_type === "single_elimination") {
        groupStage = new Duel(numParticipants);
    } else if (data.group_stage_type === "double_elimination") {
        groupStage = new Duel(numParticipants, { last: 2 });
    } else { //Round Robin
        groupStage = GroupStage(numParticipants);
    }
    let newTournamentMaster = new TournamentMaster({
        name: data.name,
        description: data.description,
        api_key: data.api_key,
        game: data.game,
        tournament_type: data.tournament_type
    });
    let groupStageTournament = new Tournament({
        parent_id: newTournamentMaster._id,
        tournament_type: data.group_stage_type,
        participants: data.participants,
        api_key:data.api_key,
        data: {
            num_players: numParticipants,
            options: {},
            state: groupStage.state.slice(),
            metadata: groupStage.metadata()
        }
    });
    newTournamentMaster.group_stage_id = groupStageTournament._id;
    newTournamentMaster.save((err, tournament) => {
        if (err) {
            res.sendStatus(500).end();
        } else {
            groupStageTournament.save((err, groupStage) => {
                if (err) {
                    res.sendStatus(500).end();
                } else {
                    res.json({
                        valid: true,
                        created: true
                    });
                }
            });
        }
    });
}
router.delete('/:id', (req, res, next) => {
    if (typeof req.body.api_key === "undefined" || typeof req.params.id === "undefined") {
        res.sendStatus(400).end();
        return next();
    }
    Tournament.find({
        parent_id: req.params.id,
        api_key:req.body.api_key
    }, (err, tournaments) => {
        if (err) {
            res.sendStatus(500).end();
        } else {
            if (tournaments === null || tournaments.length <= 0) {
                res.sendStatus(400).end();
            } else {
                let err = null;
                tournaments.forEach((tournament, index, tournaments) => {
                    Tournament.findByIdAndRemove(tournament.id, (err, tournament) => {
                        if (err) err = err;
                    });
                });
                if (!err) {
                    res.json({
                        valid: true,
                        deleted: true
                    });
                    TournamentMaster.findByIdAndRemove(req.params.id, (err, tournamentM) => {
                        if (err) console.log('Error finding master tournament in deletion');
                    });
                } else {
                    res.sendStatus(500).end();
                }
            }
        }
    });
});
module.exports = router;
