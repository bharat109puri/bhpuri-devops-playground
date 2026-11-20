import { createReadStream, existsSync } from "node:fs";
import http from "node:http";
import { extname, join, normalize } from "node:path";
import { fileURLToPath } from "node:url";

const root = join(fileURLToPath(new URL("..", import.meta.url)), "public");
const types = { ".css": "text/css; charset=utf-8", ".html": "text/html; charset=utf-8", ".js": "text/javascript; charset=utf-8" };
const server = http.createServer((request, response) => {
  if (request.url === "/healthz") return response.end(JSON.stringify({ status: "healthy" }));
  const file = normalize(join(root, request.url === "/" ? "index.html" : request.url.slice(1)));
  if (!file.startsWith(`${root}/`) || !existsSync(file)) return response.writeHead(404).end();
  response.writeHead(200, { "content-type": types[extname(file)] || "application/octet-stream" });
  createReadStream(file).pipe(response);
});
server.listen(process.env.PORT || 8080, "0.0.0.0");
