'use strict';
let mongoose = require('mongoose'),
    GroupStage = require('groupstage'),
    Duel = require('duel');

const rr = "round_robin",
    single = "single_elimination",
    double = "double_elimination";

let TournamentSchema = new mongoose.Schema({
    parent_id:mongoose.Schema.Types.ObjectId,
    tournament_type:{
        type:String,
        enum:[single,double,rr],
        required:true
    },
    participants: [{
        type: String,
        required:true
    }],
    started:{
        type:Boolean,
        default:false
    },
    data:{
        num_players:{
            type:Number,
            required:true
        },
        options:{
            last:{
                type:Number,
                default:1 //1 = single elimination, 2 =  double elimination
            }
        },
        state:{
            type:mongoose.Schema.Types.Mixed,
            required:true
        },
        metadata:{
            type:mongoose.Schema.Types.Mixed,
            required:true
        }
    }
});


module.exports = mongoose.model('Tournament', TournamentSchema);
