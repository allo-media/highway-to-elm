function parse(report) {
  const lines = report.trim().split("\n").join(",");
  const json = `[${lines}]`;
  const parsed = JSON.parse(json);
  // tranform
  return parsed
    .reduce((acc, event) => {
      console.log(acc);
      if (event.event === "runComplete") {
        acc.passed = parseInt(event.passed, 10);
        acc.failed = parseInt(event.failed, 10);
        return acc;
      } else if (event.event === "testCompleted") {
        acc.tests.push({
          label: event.labels.join(" "),
          failures: event.failures.map(failure => {
            return failure.reason.data;
          }),
        });
        return acc;
      } else {
        return acc;
      }
    }, {tests: []})
}

module.exports = parse;
