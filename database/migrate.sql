create extension if not exists postgis;

CREATE TABLE if not exists spots
(
    id     serial PRIMARY KEY,
    name   VARCHAR(60)    NOT NULL,
    phone  varchar(20),
    domain varchar(100),
    lat    decimal(10, 6) NOT NULL,
    long   decimal(10, 6) NOT NULL
);

INSERT INTO spots (name, domain, lat, long)
VALUES ('Frankie Johnnie & Luigo Too', 'http://www.domain.com/frankie', '37.386339', '-122.085823');
INSERT INTO spots (name, domain, lat, long)
VALUES ('Amicis East Coast Pizzeria', 'https://www.domain.com/Amicis', '37.38714', '-122.083235');
INSERT INTO spots (name, phone, domain, lat, long)
VALUES ('Kapps Pizza Bar & Grill', '040252064', 'www.kapps.com', '37.393885', '-122.078916');
INSERT INTO spots (name, domain, lat, long)
VALUES ('Round Table Pizza: Mountain View', 'roundtablepizzda.com', '37.402653', '-122.079354');
INSERT INTO spots (name, domain, lat, long)
VALUES ('Tony & Albas Pizza & Pasta', 'http://spot.com/tony', '37.394011', '-122.095528');
INSERT INTO spots (name, domain, phone, lat, long)
VALUES ('Oreganos Wood-Fired Pizza', 'https://spot.com/oreganos', '040252064', '37.401724', '-122.114646');

alter table spots
    add column if not exists geolocation geography(point);

update spots
set geolocation = ST_MakePoint(long, lat);

DROP FUNCTION if EXISTS get_spots_in_circle(integer, numeric, numeric);
create or replace function get_spots_in_circle(radius integer,
                                               r_lat numeric(10, 6),
                                               r_long numeric(10, 6))
    returns table
            (
                name     varchar,
                phone    varchar,
                domain   varchar,
                lat      numeric(10, 6),
                long     numeric(10, 6),
                distance integer
            )
    language plpgsql
as
$$
begin
    return query
        select a.name,
               a.phone,
               a.domain,
               a.lat,
               a.long,
               (case
                    when a.phone IS NOT NULL THEN
                            ST_Distance(a.geolocation, point(r_long, r_lat)::geometry)::INTEGER / 2
                    else
                        ST_Distance(a.geolocation, point(r_long, r_lat)::geometry)::INTEGER
                   end) as sdistance
        from spots a
        WHERE ST_DWithin(a.geolocation,
                         point(r_long, r_lat)::geometry,
                         radius)
        order by sdistance;
end;
$$;

DROP FUNCTION if EXISTS get_spots_in_square(integer, numeric, numeric);
create or replace function get_spots_in_square(radius integer,
                                               r_lat numeric(10, 6),
                                               r_long numeric(10, 6))
    returns table
            (
                name     varchar,
                phone    varchar,
                domain   varchar,
                lat      numeric(10, 6),
                long     numeric(10, 6),
                distance integer
            )
    language plpgsql
as
$$
begin
    return query
        select a.name,
               a.phone,
               a.domain,
               a.lat,
               a.long,
               (case
                    when a.phone IS NOT NULL THEN
                            ST_Distance(a.geolocation, point(r_long, r_lat)::geometry)::INTEGER / 2
                    else
                        ST_Distance(a.geolocation, point(r_long, r_lat)::geometry)::INTEGER
                   end) as sdistance
        from spots a
        WHERE (
                  SELECT ST_Contains(ST_MakePolygon(ST_MakeLine(ARRAY [
                      ST_Project(ST_Point(r_long, r_lat), radius * SQRT(2), radians(315.0)),
                      ST_Project(ST_Point(r_long, r_lat), radius * SQRT(2), radians(45.0)),
                      ST_Project(ST_Point(r_long, r_lat), radius * SQRT(2), radians(135.0)),
                      ST_Project(ST_Point(r_long, r_lat), radius * SQRT(2), radians(225.0)),
                      ST_Project(ST_Point(r_long, r_lat), radius * SQRT(2), radians(315.0))]::geometry[])),
                                     a.geolocation::geometry))
        order by sdistance;
end;
$$;
