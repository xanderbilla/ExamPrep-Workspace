const express = require("express");

// Prometheus client
const client = require("prom-client"); //Metric collection library

const { doSomeHeavyTask } = require("./util");

const app = express();
const port = process.env.PORT || 3200;

// Register the Prometheus metrics
const collectDefaultMetrics = client.collectDefaultMetrics;
collectDefaultMetrics({register: client.register});

app.get("/", (req, res) => {
  res.send("Hello World!");
});

app.get("/slow", async (req, res) => {
  try {
    const timeTaken = await doSomeHeavyTask();
    return res.json({
      status: "success",
      message: `Heavy Task completed in ${timeTaken}ms`,
    });
  } catch (error) {
    return res.status(500).json({
      status: "Error",
      error: "Internal Server Error",
    });
  }
});

app.get("/metrics", async (req, res) => {
  res.setHeader("Content-Type", client.register.contentType);
  const metrics = await client.register.metrics();
  res.send(metrics);
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
