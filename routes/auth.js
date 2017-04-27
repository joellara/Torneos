'use strict';

var express = require('express'),
    path = require('path'),
    crypto = require('crypto');

var router = express.Router();
var User = require(path.join(__dirname, '../models/User.js'));

//get Hash for specific text, with salt, or create new hash
function getHash(str, salt = crypto.randomBytes(256)) {
    let password = str.trim();
    let hash = crypto.pbkdf2Sync(password, salt.toString('hex'), 2000, 512, 'sha512');
    return [hash.toString('hex'), salt.toString('hex')];
}

router.post('/login/', function(req, res, next) {
    let [password, ] = getHash(req.body.password.trim());
    User.findOne({ email: req.body.email }, (err, user) => {
        if (err) res.sendStatus(500);
        if (typeof user !== undefined && user !== null) {
            let [password, ] = getHash(req.body.password.trim(), user.salt);
            User.findOne({
                email: req.body.email,
                password: password
            }, (err2, user2) => {
                if(err2)res.sendStatus(500);
                res.json({
                    valid:true,
                    loggedIn:true,
                    name:user.name,
                    api_key:user._id
                });
            });
        } else {
            res.json({
                valid: true,
                loggedIn: false,
                message: 'Combinación de usuario/contraseña incorrecta.'
            });
        }
    });
});

//Add new user
router.post('/signup/', function(req, res, next) {
    User.count({
        'email': req.body.email
    }, (err, count) => {
        if(err)res.sendStatus(500);
        if (count === 0) {
            let [password, salt] = getHash(req.body.password.trim());
            let newUser = new User({
                email: req.body.email,
                name: req.body.name,
                salt:salt,
                password:password
            });
            newUser.save((err,user)=>{
                if(err)res.sendStatus(500);
                res.json({
                    created:true,
                    valid:true,
                    api_key:user._id
                });
            });
        } else {
            res.json({
                created: false,
                valid: true,
                error: 'Ya existe una cuenta con ese correo.'
            });
        }

    });
});

module.exports = router;
