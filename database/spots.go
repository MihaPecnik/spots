package database

import (
	"database/sql"
	"github.com/MihaPecnik/spots/models"
)

func (d *Database) GetSpotsInRadius(request models.GetSpotsInRadiusRequest) ([]models.Spots, error) {
	var response []models.Spots
	var err error
	var rows *sql.Rows
	if request.Circle {
		rows, err = d.db.Raw("SELECT * FROM get_spots_in_circle(?,?,?) order by spot_distance", request.Radius, request.Latitude, request.Longitude).Rows()
	} else {
		rows, err = d.db.Raw("SELECT * FROM get_spots_in_square(?,?,?) order by spot_distance", request.Radius, request.Latitude, request.Longitude).Rows()
	}
	if err != nil {
		return []models.Spots{}, err
	}
	var name, phone, domain, long, lat *string
	var distance *int64

	for rows.Next() {
		err := rows.Scan(&name, &phone, &domain, &long, &lat, &distance)
		if err != nil {
			return []models.Spots{}, err
		}
		response = append(response, models.Spots{
			Name:     name,
			Phone:    phone,
			Domain:   domain,
			Long:     long,
			Lat:      lat,
			Distance: distance,
		})
	}

	return response, err
}
