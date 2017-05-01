'use strict';
var mongoose = require('mongoose');

const single_stage = "single_stage",
    two_stage = "two_stage";

var TournamentMasterSchema = new mongoose.Schema({
    name: {
        type: String,
        required: true
    },
    description: {
        type:String,
        required:true
    },
    game: {
        type: String,
        required: true
    },
    tournament_type: {
        type: String,
        enum: [single_stage, two_stage],
        required: true
    },
    final_stage_id: {
        type: mongoose.Schema.Types.ObjectId,
        required: false
    },
    group_stage_id: {
        type: mongoose.Schema.Types.ObjectId,
        required: true
    }
});

module.exports = mongoose.model('TournamentMaster', TournamentMasterSchema);
