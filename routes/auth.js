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
    if(typeof req.body === "undefined" || typeof req.body.email === "undefined" || typeof req.body.password === "undefined"){
        res.sendStatus(400).end();
    }else{
        let [password, ] = getHash(req.body.password.trim());
        User.findOne({ email: req.body.email }, (err, user) => {
            if (err) {
                res.sendStatus(500).end();
            }else{
                if (typeof user !== undefined && user !== null) {
                    let [password, ] = getHash(req.body.password.trim(), user.salt);
                    User.findOne({
                        email: req.body.email,
                        password: password
                    }, (err2, user2) => {
                        if(err2){
                            res.sendStatus(500).end();
                        }else{
                            res.json({
                                valid:true,
                                loggedIn:true,
                                name:user.name,
                                api_key:user._id,
                                emai:user.email
                            });
                        }
                    });
                } else {
                    res.json({
                        valid: true,
                        loggedIn: false,
                        message: 'Combinación de usuario/contraseña incorrecta.'
                    });
                }
            }
        });
    }
});

//Add new user
router.post('/signup/', function(req, res, next) {
    if(typeof req.body === "undefined" || typeof req.body.email === "undefined" || typeof req.body.password === "undefined" || typeof req.body.name === "undefined"){
        res.sendStatus(400).end();
    }else{
        User.count({
            'email': req.body.email
        }, (err, count) => {
            if (err) {
                res.sendStatus(500).end();
            }else{
                 if (count === 0) {
                    let [password, salt] = getHash(req.body.password.trim());
                    let newUser = new User({
                        email: req.body.email,
                        name: req.body.name,
                        salt:salt,
                        password:password
                    });
                    newUser.save((err,user)=>{
                        if (err) {
                            res.sendStatus(500).end();
                        }else{
                            res.json({
                                created:true,
                                valid:true,
                                api_key:user._id,
                                name:user.name,
                                email:user.email
                            });
                        }
                    });
                } else {
                    res.json({
                        created: false,
                        valid: true,
                        message: 'Ya existe una cuenta con ese correo.'
                    });
                }
            }
        });
    }
});

module.exports = router;
