var express = require('express'),
  app = express(),
  port = process.env.PORT || 80;

app.listen(port);

console.log('Tournament API server started on: ' + port);
