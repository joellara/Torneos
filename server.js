var express = require('express'),
    bodyParser = require('body-parser'),
    path = require('path'),
    app = express(),
    mongoose = require('mongoose'),
    port = process.env.PORT || 80;

var tournament = require(path.join(__dirname, 'routes/tournament.js'));
var auth = require(path.join(__dirname, 'routes/auth.js'));

app.use(express.static(path.join(__dirname, 'public')));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));

app.use('/tournament', tournament);
app.use('/auth', auth);


//Catch 404
app.use(function(req, res, next) {
    res.sendStatus(404);
});
mongoose.Promise = global.Promise;
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost/tournaments');
mongoose.connection.on('open', () => {
    console.log('Connected to MongoDB');
    app.listen(port, () => {
        console.log('Tournament API server started on: ' + port);
    });
});
mongoose.connection.on('error', err => {
    console.log('Mongoose Error. ' + err);
});
