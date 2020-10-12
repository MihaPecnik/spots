package models

type Spots struct {
	Name     *string `json:"spot_name"`
	Phone    *string `json:"spot_phone,omitempty"`
	Domain   *string `json:"spot_domain"`
	Long     *string `json:"spot_long" sql:"type:decimal(10,6);"`
	Lat      *string `json:"spot_lat" sql:"type:decimal(10,6);"`
	Distance *int64  `json:"spot_distance"`
}

type GetSpotsInRadiusRequest struct {
	Radius    int64  `json:"radius"`
	Latitude  string `json:"latitude"`
	Longitude string `json:"longitude"`
	Circle    bool   `json:"circle"`
}

