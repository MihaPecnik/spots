package database

import (
	"flag"
	_ "github.com/lib/pq"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"io/ioutil"
	"log"
)

type Database struct {
	db *gorm.DB
}

func NewDatabase() (*Database, error) {
	migrate := flag.Bool("migrate", false, "database migration")
	database := flag.String("database", "", "database connection")
	flag.Parse()
	conn, err := gorm.Open(postgres.Open(*database), &gorm.Config{})

	if err != nil {
		return nil, err
	}
	log.Println("successfully created database connection")


	if *migrate{
		query, err := ioutil.ReadFile("database/migrate.sql")
		if err != nil {
			panic(err)
		}
		if err := conn.Exec(string(query)).Error; err != nil {
			panic(err)
		}
	}

	return &Database{db: conn}, nil
}


