package main

import (
	"github.com/MihaPecnik/spots/database"
	"github.com/MihaPecnik/spots/handler"
	"github.com/MihaPecnik/spots/server"
	"log"
)

func main(){
	db, err := database.NewDatabase()
	if err != nil {
		log.Fatal(err)
	}

	h := handler.NewHandler(db)
	s := server.NewServer(h)
	log.Fatal(s.Serve(":8080"))
}