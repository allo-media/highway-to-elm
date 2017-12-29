const os = require("os");
const path = require("path");
const fs = require("fs");
const { promisify } = require("util");
const { compileToString } = require("node-elm-compiler");
const express = require("express");
const bodyParser = require("body-parser");
const cors = require("cors");

const mkdtemp = promisify(fs.mkdtemp);
const readdir = promisify(fs.readdir);
const readFile = promisify(fs.readFile);
const writeFile = promisify(fs.writeFile);

const app = express();
app.use(bodyParser.urlencoded({ extended: true }));
app.use("/", express.static("public"));
app.use(cors());

/**
TODO:
- the exercises folder should actually contain folders, one per exercise, with:
  * a README.md file for the pitch
  * A Test.elm file containing test code.
  * optionaly, a solution (a sample Main.elm file)
- on first user request, store a cookie, generate a tmp user session dir
- the run endpoint should accept elm code wit tests + implementation
  * maybe two, tests + impl.
- the script should create the file(s) in the user session directory from the
  submitted code contents
- the script should run the tests against these file(s)
- the result should be parsed and exposed as the http response
  * check https://github.com/rtfeldman/node-test-runner#--report
*/

function extractExercise(id) {
  const folder = `./exercises/${id}`;
  let record = {};
  return readFile(`${folder}/README.md`, "utf8")
    .then(readme => {
      const [_, rawMeta, body] = readme.split("---\n");
      const meta = rawMeta
        .split("\n")
        .map(line => line.split(":").map(w => w.trim()))
        .reduce((acc, entry) => {
          const [key, value] = entry;
          return { ...acc, [key]: value };
        }, {});
      record = {
        id: parseInt(id, 10),
        title: meta.title,
        description: meta.description,
        body: body.trim()
      };
      return readFile(`${folder}/Main.elm`, "utf8");
    })
    .then(main => {
      record.main = main;
      // TODO: test file contents
      return record;
    });
}

app.get("/exercises", (req, res) => {
  readdir("./exercises")
    .then(files => {
      // XXX: instead of reading on every request, we should rather read it on
      // app startup and cache it.
      return Promise.all(files.map(extractExercise));
    })
    .then(exercises => {
      res.send(exercises);
    })
    .catch(err => {
      res
        .status(500)
        .send({ error: "Cannot retrieve exercises: " + err.message });
    });
});

app.post("/compile", (req, res) => {
  const { elm: elmCode } = req.body;
  // FIXME: we should have a dedicated tmp dir per user session
  const sourceFile = app.hteTmp + "/Main.elm";
  writeFile(sourceFile, elmCode)
    .then(() => {
      return compileToString([sourceFile], { yes: true, output: "index.html" });
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
    mkdtemp(path.join(os.tmpdir(), "hte-"))
      .then(folder => {
        app.hteTmp = folder;
        app.listen(3000, resolve);
      });
  });
}

startServer()
  .then(() => {
    console.log('App listening on http://localhost:3000 !')
  })
  .catch(err => {
    console.error(err);
  });
