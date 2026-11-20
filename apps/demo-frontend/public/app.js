const status = document.querySelector("#status");
try {
  const response = await fetch("/healthz");
  status.textContent = response.ok ? "Health check passed — frontend is ready." : "Health check failed.";
  status.classList.toggle("failed", !response.ok);
} catch {
  status.textContent = "Health check could not be reached.";
  status.classList.add("failed");
}
