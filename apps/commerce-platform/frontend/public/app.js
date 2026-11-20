const result = document.querySelector("#result");
document.querySelector("#load").addEventListener("click", async () => {
  result.textContent = "Loading…";
  try { result.textContent = JSON.stringify(await (await fetch("/api/products")).json(), null, 2); }
  catch { result.textContent = "Catalog API is unavailable."; }
});
