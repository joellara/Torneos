var express = require('express'),
  app = express(),
  port = process.env.PORT || 80;

//app.listen(port);

const groupstage = require('groupstage');
var gs = groupstage(5);
gs.score({s:1,r:1,m:1},[1,0]);
console.log(gs.state.slice());
console.log('Tournament API server started on: ' + port);
