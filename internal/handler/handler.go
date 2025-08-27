package handler

import (
	"gomaketest/views/pages"
	"net/http"
)

func HomePage(w http.ResponseWriter, r *http.Request) {
	component := pages.HomePage(r.URL.Path)
	component.Render(r.Context(), w)
}

func AboutPage(w http.ResponseWriter, r *http.Request) {
	component := pages.AboutPage(r.URL.Path)
	component.Render(r.Context(), w)
}
