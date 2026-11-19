import http from "node:http";

const port = process.env.PORT || 8080;
const server = http.createServer((request, response) => {
  const body = request.url === "/healthz"
    ? { status: "healthy" }
    : { service: "demo-node", status: "ok" };
  response.writeHead(200, { "content-type": "application/json" });
  response.end(JSON.stringify(body));
});

server.listen(port, "0.0.0.0");
