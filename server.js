var express = require('express'),
    path = require('path'),
    app = express(),
    port = process.env.PORT || 80;

var tournament = require(path.join(__dirname,'routes/tournament.js'));
var auth = require(path.join(__dirname,'routes/auth.js'));

app.use(express.static(path.join(__dirname, 'public')));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));

app.use('tournament',tournament);
app.use('auth',auth);


//Catch 404
app.use(function(req, res, next) {
    res.sendStatus(404);
});

app.listen(port);
console.log(gs.state.slice());
console.log('Tournament API server started on: ' + port);
