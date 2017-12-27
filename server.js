const os = require("os");
const path = require("path");
const fs = require("fs");
const { promisify } = require("util");
const { compileToString } = require("node-elm-compiler");
const express = require("express");
const bodyParser = require("body-parser");

const mkdtemp = promisify(fs.mkdtemp);
const readdir = promisify(fs.readdir);
const readFile = promisify(fs.readFile);
const writeFile = promisify(fs.writeFile);

const app = express();
app.use(bodyParser.urlencoded({ extended: true }));
app.use("/", express.static('public'))

function extractExercise(filePath) {
  return readFile("./exercises/" + filePath, "utf8")
    .then(content => {
      const [_, rawMeta, body] = content.split("---\n");
      const meta = rawMeta
        .split("\n")
        .map(line => line.split(":").map(w => w.trim()))
        .reduce((acc, entry) => {
          const [key, value] = entry;
          return {...acc, [key]: value};
        }, {});
      return {
        title: meta.title,
        description: meta.description,
        body: body.trim(),
      };
    });
}

app.get("/exercises", (req, res) => {
  readdir("./exercises")
    .then((files) => {
      // XXX: instead of reading on every request, we should rather read it on
      // app startup and cache it. 
      return Promise.all(files.map(extractExercise));
    })
    .then((exercises) => {
      res.send(exercises);
    })
    .catch(err => {
      res.status(500).send({ error: "Cannot retrieve exercises: " + err.message });
    });
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
      res.status(400).send({ error: "Invalid request: " + err.toString() });
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
  });
