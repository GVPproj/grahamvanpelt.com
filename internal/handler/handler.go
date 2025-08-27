package handler

import (
	"net/http"

	"gomaketest/views/pages"
)

func HomePage(w http.ResponseWriter, r *http.Request) {
	component := pages.HomePage()
	component.Render(r.Context(), w)
}
