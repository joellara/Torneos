'use strict';
let mongoose = require('mongoose'),
    GroupStage = require('groupstage'),
    Duel = require('duel');

const rr = "round_robin",
    single = "single_elimination",
    double = "double_elimination";
const first = "first_stage",
    second = "second_stage";
const single_stage = "single_stage",
    two_stage = "two_stage";
let TournamentSchema = new mongoose.Schema({
    parent_id: {
        type: mongoose.Schema.Types.ObjectId,
        required: true
    },
    sibling_id : {
        type: mongoose.Schema.Types.ObjectId
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
    stage:{
        type:String,
        enum:[first,second],
        required:true
    },
    parent_stages:{
        type:String,
        enum:[single_stage,two_stage],
        required:true
    },
    participants: [{
        type: String,
        required: true
    }],
    started: {
        type: Boolean,
        default: false
    },
    finished:{
        type:Boolean,
        default:false
    },
    data: {
        num_players: Number,
        state:mongoose.Schema.Types.Mixed,
        metadata:  mongoose.Schema.Types.Mixed,
    },
    matches:mongoose.Schema.Types.Mixed
});


module.exports = mongoose.model('Tournament', TournamentSchema);
