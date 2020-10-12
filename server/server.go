package server

import (
	"github.com/gorilla/mux"
	"net/http"
)

type Server struct {
	router *mux.Router
}

func (s *Server) Serve(port string) error {
	return http.ListenAndServe(port, s.router)
}

type Handler interface {
	GetSpotsInRadius(w http.ResponseWriter, r *http.Request)
}


func NewServer(h Handler) *Server {
	router := mux.NewRouter().StrictSlash(true)
	router.HandleFunc("/api/v1/spots", h.GetSpotsInRadius).Methods("PUT")

	return &Server{
		router: router,
	}
}
