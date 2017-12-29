const os = require("os");
const path = require("path");
const fs = require("fs");
const { promisify } = require("util");
const { compileToString } = require("node-elm-compiler");
const express = require("express");
const bodyParser = require("body-parser");
const cors = require("cors");
const child_process = require("child_process");
const parser = require("./parser");

const mkdtemp = promisify(fs.mkdtemp);
const readdir = promisify(fs.readdir);
const readFile = promisify(fs.readFile);
const writeFile = promisify(fs.writeFile);
const exec = promisify(child_process.exec);

const app = express();
app.use(bodyParser.urlencoded({ extended: true }));
app.use("/", express.static("public"));
app.use(cors());

let exercises;

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
      return readFile(`${folder}/Test.elm`, "utf8");
    })
    .then(test => {
      record.test = test;
      return record;
    });
}

app.get("/exercises", (req, res) => {
  res.send(exercises);
});

app.post("/run", (req, res) => {
  const { elm: elmCode, id } = req.body;
  let targetFilePath;
  let baseFolder;
  let exPath = __dirname + "/exercises/" + id;
  // Create a temporary directory for the lifepan of this request
  mkdtemp(path.join(os.tmpdir(), "hte-"))
    .then(tmpFolder => {
      // copy the test template
      baseFolder = tmpFolder;
      return exec(`cp -r ${__dirname}/template/* ${tmpFolder}`);
    })
    .then(() => {
      targetFilePath = `${baseFolder}/Main.elm`;
      return writeFile(targetFilePath, elmCode);
    })
    .then(() => {
      return exec(`cp ${exPath}/Test.elm ${baseFolder}/tests/Test.elm`);
    })
    .then(() => {
      return exec(`elm-test ${baseFolder} --report=json`);
    })
    .then((err, stdout, stderr) => {
      return parser.parse(stdout);
    })
    .catch(err => {
      res.status(400).send({ error: err.toString() });
    })
    .then(() => {
      // Remove the tmp directory
      // TODO
    });
});

app.post("/compile", (req, res) => {
  const { elm: elmCode } = req.body;
  let sourceFile;
  // Create a temporary directory for the lifepan of this request
  mkdtemp(path.join(os.tmpdir(), "hte-"))
    .then(folder => {
      sourceFile = `${folder}/Main.elm`;
      return writeFile(sourceFile, elmCode);
    })
    .then(() => {
      return compileToString([sourceFile], { yes: true, output: "app.js" });
    })
    .then(data => {
      const jsCode = data.toString();
      res.send(`<html><body><script>${jsCode}</script><script>Elm.Main.fullscreen()</script></body></html>`);
    })
    .catch(err => {
      res.status(400).send(`<html><body><pre>${err.toString()}</pre></body></html>`);
    })
    .then(() => {
      // Remove the tmp directory
      // TODO
    });
});

function startServer() {
  return readdir("./exercises")
    .then(files => {
      return Promise.all(files.map(extractExercise));
    })
    .then(results => {
      // Store the exercises in memory
      exercises = results;
      // Run ther server
      return new Promise(resolve => {
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
