# Polyglot service examples

`demo-spring` and `demo-php` extend the same `GET /healthz` and port `8080` deployment contract as the existing Python, Node.js, and Go services.

The Spring example is a compact Spring Boot MVC service built with Maven and executed as a non-root Java 21 runtime. The PHP example intentionally uses the built-in server only as a local-lab pattern; deploy PHP-FPM behind a managed web server in production.
