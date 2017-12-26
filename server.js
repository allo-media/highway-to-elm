const os = require("os");
const path = require("path");
const fs = require("fs");
const { promisify } = require("util");
const { compileToString } = require("node-elm-compiler");
const express = require("express");
const bodyParser = require("body-parser");

const mkdtemp = promisify(fs.mkdtemp);
const writeFile = promisify(fs.writeFile);

const app = express();
app.use(bodyParser.urlencoded({ extended: true }));

app.get("/", (req, res) => {
  res.sendFile(__dirname + "/public/home.html");
});

app.post("/compile", (req, res) => {
  const { elm: elmCode } = req.body;
  // FIXME: we should have a dedicated tmp dir per user session
  const sourceFile = app.hteTmp + "/Main.elm";
  writeFile(sourceFile, elmCode)
    .then(() => {
      return compileToString([sourceFile], { yes: true, output: "index.html" })
    })
    .then(function (data) {
      res.send(data.toString());
    })
    .catch(err => {
      res.send(400, { error: "Invalid request: " + err.toString() });
    });
});

function startServer() {
  return new Promise((resolve, reject) => {
    mkdtemp(path.join(os.tmpdir(), 'hte-'))
      .then((folder) => {
        app.hteTmp = folder;
        app.listen(3000, resolve);
      });
  });
}

startServer()
  .then(() => {
    console.log('App listening on port 3000!')
  })
  .catch(err => {
    console.error(err);
  })
