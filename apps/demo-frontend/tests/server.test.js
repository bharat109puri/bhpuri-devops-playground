import assert from "node:assert/strict";
import test from "node:test";
import { requestHandler } from "../src/server.js";

function call(url) {
  const response = {
    body: "",
    headers: {},
    status: 0,
    end(chunk = "") { this.body += chunk; },
    writeHead(status, headers) { this.status = status; this.headers = headers; }
  };
  requestHandler({ url }, response);
  return response;
}

test("health endpoint returns a healthy response", () => {
  const response = call("/healthz");
  assert.equal(response.status, 200);
  assert.deepEqual(JSON.parse(response.body), { status: "healthy" });
});

test("unknown route returns 404", () => {
  const response = call("/missing");
  assert.equal(response.status, 404);
});
