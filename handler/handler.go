package handler

import (
	"encoding/json"
	"github.com/MihaPecnik/spots/models"
	"net/http"
)

type Database interface {
	GetSpotsInRadius(request models.GetSpotsInRadiusRequest) ([]models.Spots, error)
}

type Handler struct {
	DB Database
}

func NewHandler(database Database) *Handler {
	return &Handler{
		DB: database,
	}
}

func (h *Handler) GetSpotsInRadius(w http.ResponseWriter, r *http.Request) {
	var request models.GetSpotsInRadiusRequest
	err := json.NewDecoder(r.Body).Decode(&request)
	if err != nil {
		respondError(w, http.StatusBadRequest, err.Error())
		return
	}

	response, err := h.DB.GetSpotsInRadius(request)
	if err != nil {
		respondError(w, http.StatusInternalServerError, err.Error())
		return
	}

	respondJSON(w, http.StatusOK, response)
}

func respondJSON(w http.ResponseWriter, status int, payload interface{}) {
	response, _ := json.Marshal(payload)
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	w.Write(response)
}

func respondError(w http.ResponseWriter, code int, message string) {
	respondJSON(w, code, map[string]string{"error": message})
}
