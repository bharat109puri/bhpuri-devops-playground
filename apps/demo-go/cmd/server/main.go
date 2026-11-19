package main

import (
	"encoding/json"
	"net/http"
)

func main() {
	http.HandleFunc("/healthz", func(w http.ResponseWriter, _ *http.Request) {
		json.NewEncoder(w).Encode(map[string]string{"status": "healthy"})
	})
	http.HandleFunc("/", func(w http.ResponseWriter, _ *http.Request) {
		json.NewEncoder(w).Encode(map[string]string{"service": "demo-go", "status": "ok"})
	})
	panic(http.ListenAndServe(":8080", nil))
}
