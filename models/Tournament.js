'use strict';
let mongoose = require('mongoose'),
    GroupStage = require('groupstage'),
    Duel = require('duel');

const rr = "round_robin",
    single = "single_elimination",
    double = "double_elimination";

let TournamentSchema = new mongoose.Schema({
    parent_id: {
        type: mongoose.Schema.Types.ObjectId,
        required: true
    },
    api_key: {
        type: mongoose.Schema.Types.ObjectId,
        required: true
    },
    tournament_type: {
        type: String,
        enum: [single, double, rr],
        required: true
    },
    participants: [{
        type: String,
        required: true
    }],
    started: {
        type: Boolean,
        default: false
    },
    data: {
        num_players: Number,
        state:mongoose.Schema.Types.Mixed,
        metadata:  mongoose.Schema.Types.Mixed,
    },
    matches:mongoose.Schema.Types.Mixed
});


module.exports = mongoose.model('Tournament', TournamentSchema);
