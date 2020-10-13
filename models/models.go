package models

type Spots struct {
	Name     *string `json:"name"`
	Phone    *string `json:"phone,omitempty"`
	Domain   *string `json:"domain"`
	Long     *string `json:"long" sql:"type:decimal(10,6);"`
	Lat      *string `json:"lat" sql:"type:decimal(10,6);"`
	Distance *int64  `json:"distance"`
}

type GetSpotsInRadiusRequest struct {
	Radius    int64  `json:"radius"`
	Latitude  string `json:"latitude"`
	Longitude string `json:"longitude"`
	Circle    bool   `json:"circle"`
}
