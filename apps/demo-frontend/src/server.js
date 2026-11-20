import { createReadStream, existsSync } from "node:fs";
import http from "node:http";
import { extname, join, normalize } from "node:path";
import { fileURLToPath } from "node:url";

const port = Number(process.env.PORT || 8080);
const publicDir = join(fileURLToPath(new URL("..", import.meta.url)), "public");
const contentTypes = {
  ".css": "text/css; charset=utf-8",
  ".html": "text/html; charset=utf-8",
  ".js": "text/javascript; charset=utf-8",
  ".json": "application/json; charset=utf-8"
};

function sendJson(response, status, body) {
  response.writeHead(status, { "content-type": "application/json; charset=utf-8" });
  response.end(JSON.stringify(body));
}

export function requestHandler(request, response) {
  const pathname = new URL(request.url, "http://localhost").pathname;
  if (pathname === "/healthz") return sendJson(response, 200, { status: "healthy" });
  if (pathname === "/readyz") return sendJson(response, 200, { status: "ready" });

  const requestedPath = pathname === "/" ? "index.html" : pathname.slice(1);
  const filename = normalize(join(publicDir, requestedPath));
  if (!filename.startsWith(`${publicDir}/`) || !existsSync(filename)) {
    response.writeHead(404, { "content-type": "text/plain; charset=utf-8" });
    return response.end("Not found");
  }

  response.writeHead(200, {
    "content-type": contentTypes[extname(filename)] || "application/octet-stream",
    "cache-control": "public, max-age=300"
  });
  createReadStream(filename).pipe(response);
}

export const server = http.createServer(requestHandler);

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  server.listen(port, "0.0.0.0", () => console.log(`demo-frontend listening on :${port}`));
}
