const { compileToString } = require("node-elm-compiler");
const express = require("express");
const app = express();

app.get("/compile", (req, res) => {
  compileToString(["./Main.elm"], { yes: true, output: "index.html" })
    .then(function (data) {
      res.send(data.toString());
    })
    .catch(err => {
      res.send(400, {error: "Invalid request"});
    });
});

app.listen(3000, () => console.log('Example app listening on port 3000!'))
