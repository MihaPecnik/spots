package database

import (
	"github.com/MihaPecnik/spots/models"
)

func (d *Database) GetSpotsInRadius(request models.GetSpotsInRadiusRequest) ([]models.Spots, error) {
	var response []models.Spots
	var err error
	if request.Circle {
		err = d.db.Raw("SELECT * FROM get_spots_in_circle(?,?,?)", request.Radius, request.Latitude, request.Longitude).Scan(&response).Error
	} else {
		err = d.db.Raw("SELECT * FROM get_spots_in_square(?,?,?)", request.Radius, request.Latitude, request.Longitude).Scan(&response).Error
	}
	if err != nil {
		return []models.Spots{}, err
	}
	return response, err
}
