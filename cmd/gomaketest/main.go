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
		fmt.Println("Usage: music serve")
	}
}

func startServer() {
	mux := http.NewServeMux()

	// Static files
	mux.Handle("/static/", http.StripPrefix("/static/", http.FileServer(http.Dir("static"))))

	// Routes
	mux.HandleFunc("/", handler.HomePage)
	mux.HandleFunc("/about", handler.AboutPage)

	port := ":8080"
	fmt.Printf("Server starting on http://localhost%s\n", port)

	if err := http.ListenAndServe(port, mux); err != nil {
		log.Fatal(err)
	}
}
