package main

import (
	"fmt"
	"music/internal/handler"
	"log"
	"net/http"
	"os"
)

func main() {
	if len(os.Args) > 1 && os.Args[1] == "serve" {
		startServer()
	} else {
		// Default to serving if no args (for Railway)
		startServer()
	}
}

func startServer() {
	mux := http.NewServeMux()

	// Static files
	mux.Handle("/static/", http.StripPrefix("/static/", http.FileServer(http.Dir("static"))))

	// Routes
	mux.HandleFunc("/", handler.HomePage)
	mux.HandleFunc("/about", handler.AboutPage)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	port = ":" + port
	fmt.Printf("Server starting on port %s\n", port)

	if err := http.ListenAndServe(port, mux); err != nil {
		log.Fatal(err)
	}
}
