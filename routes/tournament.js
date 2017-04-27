'use strict';
var path = require('path');
var express = require('express');
var router = express.Router();
var TournamentMaster = require(path.join(__dirname, '../models/TournamentMaster.js'));
var Tournament = require(path.join(__dirname, '../models/Tournament.js'));

router.get('/',(req,res,next)=>{

});

router.get('/:id',(req,res,next)=>{

});

router.post('/',(req,res,next)=>{

});

router.delete('/:id',(req,res,next)=>{

});
module.exports = router;