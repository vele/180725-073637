package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		envVars := map[string]string{}
		for _, e := range os.Environ() {
			pair := splitEnv(e)
			envVars[pair[0]] = pair[1]
		}
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(envVars)
	})

	http.HandleFunc("/healthz", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("ok"))
	})

	fmt.Println("Server starting on port 8080...")
	http.ListenAndServe(":8080", nil)
}

func splitEnv(e string) []string {
	for i := 0; i < len(e); i++ {
		if e[i] == '=' {
			return []string{e[:i], e[i+1:]}
		}
	}
	return []string{e, ""}
}

