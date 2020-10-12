# Spots

## How to run application
  go run main.go [-parameters]
  
  parameters examples:
   * --migrate //migrate the databse
   * --database  //databse connection

## Api endpoints
* localhost:8080
###  Get spots in radius
* Method:PUT 
* Path: /api/v1/api/v1/spots
>For circle
```json
request:
{
   "radius":1400,
   "latitude" : "37.394011",
   "longitude":"-122.095528",
   "circle": true
}
```

>For square
```json
request:
{
   "radius":1400,
   "latitude" : "37.394011",
   "longitude":"-122.095528",
   "circle": false
}
```
response:
```json
[
    {
        "spot_name": "Tony & Albas Pizza & Pasta",
        "spot_domain": "http://spot.com/tony",
        "spot_long": "37.394011",
        "spot_lat": "-122.095528",
        "spot_distance": 0
    },
    {
        "spot_name": "Frankie Johnnie & Luigo Too",
        "spot_domain": "domain.com",
        "spot_long": "37.386339",
        "spot_lat": "-122.085823",
        "spot_distance": 1210
    },
    {
        "spot_name": "Amicis East Coast Pizzeria",
        "spot_domain": "domain.com",
        "spot_long": "37.387140",
        "spot_lat": "-122.083235",
        "spot_distance": 1329
    }
]
status:200
```
