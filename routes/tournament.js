'use strict';
var path = require('path'),
    express = require('express'),
    Duel = require('duel'),
    GroupStage = require('groupstage'),
    _ = require('underscore');

const constants = require('../config/constants.js');
const tournament_format = constants.tournament_format;
const tournament_stage = constants.tournament_stage;
const num_stages = constants.num_stages;

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
router.get('/:id', (req, res, next) => { //Child tournament
    if (typeof req.params.id === "undefined") {
        res.sendStatus(400).end();
        return next();
    }
    Tournament.findOne({
        _id: req.params.id
    }, (err, tournament) => {
        if (err) {
            res.sendStatus(500).end();
        } else {
            if (tournament !== null) {
                tournament.data = {};
                res.json({
                    valid: true,
                    found: true,
                    tournament: tournament
                });
            } else {
                res.json({
                    valid: true,
                    found: false,
                    message: "No se encontro el torneo."
                });
            }
        }
    });
});

router.get('/master/:id', (req, res, next) => {
    if (typeof req.body === "undefined" || typeof req.params.id === "undefined") {
        res.sendStatus(400).end();
        return next();
    }
    TournamentMaster.findOne({
        _id: req.params.id
    }, (err, tournament) => {
        if (err) {
            res.sendStatus(500).end();
        } else {
            if (tournament !== null) {
                res.json({
                    valid: true,
                    found: true,
                    tournament: tournament,
                });
            } else {
                res.json({
                    valid: true,
                    found: false,
                    message: "No se encontró el torneo."
                });
            }
        }
    });
});
/*
 * Creates new tournament
 *
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
    if (req.body.tournament_type === num_stages.two_stage && typeof req.body.final_stage_type === "undefined") {
        res.sendStatus(400).end();
        return next();
    }

    if (req.body.tournament_type === num_stages.single_stage) {
        createSingleStage(req.body, res);
    } else {
        createDoubleStage(req.body, res);
    }
});

function createSingleStage(data, res) {
    var numParticipants = data.participants.length;
    let groupStage = createTournament(data.group_stage_type, data.participants.length);
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
        api_key: data.api_key,
        stage: tournament_stage.first,
        parent_stages: num_stages.single_stage,
        data: {
            num_players: numParticipants,
            options: {},
            state: _.clone(groupStage.state),
            metadata: groupStage.metadata()
        },
        matches: _.clone(groupStage.matches)
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

function createDoubleStage(data, res) {
    var numParticipants = data.participants.length;
    let groupStage = createTournament(data.group_stage_type, data.participants.length);
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
        api_key: data.api_key,
        stage: tournament_stage.first,
        parent_stages: num_stages.two_stage,
        data: {
            num_players: numParticipants,
            state: _.clone(groupStage.state),
            metadata: groupStage.metadata()
        },
        matches: _.clone(groupStage.matches)
    });
    let finalStageTournament = new Tournament({
        parent_id: newTournamentMaster._id,
        tournament_type: data.final_stage_type,
        participants: [],
        sibling_id: groupStageTournament._id,
        stage: tournament_stage.second,
        parent_stages: num_stages.two_stage,
        api_key: data.api_key
    });
    groupStageTournament.sibling_id = finalStageTournament._id;
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
                    finalStageTournament.save((err) => {
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
//delete tournament and
router.delete('/:id', (req, res, next) => {
    if (typeof req.body.api_key === "undefined" || typeof req.params.id === "undefined") {
        res.sendStatus(400).end();
        return next();
    }
    Tournament.find({
        parent_id: req.params.id,
        api_key: req.body.api_key
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

router.post('/score/:id', (req, res, next) => {
    if (typeof req.body.api_key === "undefined" ||  typeof req.params.id === "undefined" || typeof req.body.results === "undefined") {
        res.sendStatus(400).end();
        return next();
    }
    Tournament.findOne({
        api_key: req.body.api_key,
        _id: req.params.id
    }, (err, tournament) => {
        if (err) {
            res.sendStatus(500).end();
        } else {
            if (tournament === null) {
                res.json({
                    valid: true,
                    found: false,
                    message: "No se encontro el torneo"
                });
            } else {
                let trn;
                if (!tournament.started) {
                    trn = createTournament(tournament.tournament_type, tournament.data.num_players);
                } else {
                    trn = restoreTournament(tournament.tournament_type, tournament.data);
                }
                let reason;
                for (var i = 0; i < req.body.results.length; i++) {
                    reason = trn.unscorable(req.body.results[i].id, req.body.results[i].result);
                    if (reason !== null) {
                        console.log(reason);
                        break;
                    } else {
                        trn.score(req.body.results[i].id, req.body.results[i].result);
                    }
                }
                if (reason !== null) {
                    res.sendStatus(400).end();
                } else {
                    tournament.started = true;
                    tournament.matches = _.clone(trn.matches);
                    tournament.data.state = _.clone(trn.state);
                    tournament.data.metadata = trn.metadata();
                    if (trn.isDone()) {
                        tournament.finished = true;
                    }
                    console.log('Tournament finished?: ', trn.isDone());
                    tournament.save((err) => {
                        if (err) {
                            res.sendStatus(500).end();
                        } else {
                            if (trn.isDone() && tournament.parent_stages === num_stages.two_stage && tournament.stage == tournament_stage.first) {
                                Tournament.findOne({
                                    _id: tournament.sibling_id
                                }, (err, tournamentSibling) => {
                                    if (err) {
                                        console.log("Ohh shooo, we had a problem");
                                    } else {
                                        if (tournamentSibling === null) {
                                            console.log("Ohh shooo, we couldn't find sibling");
                                        } else {
                                            var participants = trn.results().slice(0, 4);
                                            console.log("next participants",participants);
                                            let secondTrn = createTournament(tournamentSibling.tournament_type, 4);
                                            console.log(secondTrn);
                                            tournamentSibling.participants = participants;
                                            tournamentSibling.data = {
                                                num_players: 4,
                                                state: _.clone(secondTrn.state),
                                                metadata: secondTrn.metadata()
                                            };
                                            tournamentSibling.matches = _.clone(secondTrn.matches);
                                            tournamentSibling.save((err) => {
                                                if (err) console.log("Ohh shaiza, couldn't create second tournament", err);
                                            });
                                        }
                                    }
                                });
                            }
                            res.json({
                                valid: true,
                                scored: true
                            });
                        }
                    });
                }
            }
        }
    });
});
/**********Helper function *****************/
//create Tournament based on type and number of players
function createTournament(type, num_players) {
    let trn;
    if (type === tournament_format.single) {
        trn = new Duel(num_players, { short: true });
    } else if (type === tournament_format.double) {
        trn = new Duel(num_players, { last: 2, short: true });
    } else { //Round Robin
        trn = GroupStage(num_players);
    }
    return trn;
}
/*
 * @param type Tournament Type (single elimination, double elimnination, round robin)
 * @param data.num_players
 * @param data.state = inst.state.slice()
 * @param data.metadata = insta.metadata()
 */
function restoreTournament(type, data) {
    let trn;
    if (type === tournament_format.single) {
        trn = Duel.restore(data.num_players, { short: true }, data.state, data.metadata);
    } else if (type === tournament_format.double) {
        trn = Duel.restore(data.num_players, { last: 2, short: true }, data.state, data.metadata);
    } else { //Round Robin
        trn = GroupStage.restore(data.num_players, {}, data.state, data.metadata);
    }
    return trn;
}
module.exports = router;
