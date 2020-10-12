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
                spot_name     varchar,
                spot_phone    varchar,
                spot_domain   varchar,
                spot_lat      numeric(10, 6),
                spot_long     numeric(10, 6),
                spot_distance integer
            )
    language plpgsql
as
$$
declare
    var_r record;
begin
    for var_r in (
        select *, ST_Distance(a.geolocation, point(r_long, r_lat)::geometry)::INTEGER as distance
        from spots a
        WHERE ST_DWithin(geolocation,
                         point(r_long, r_lat)::geometry,
                         radius)
    )
        loop
            if var_r.phone IS NOT NULL then
                spot_distance := var_r.distance / 2;
            else
                spot_distance := var_r.distance;
            end if;
            spot_name := var_r.name;
            spot_phone = var_r.phone;
            spot_domain = var_r.domain;
            spot_lat = var_r.lat;
            spot_long = var_r.long;
            return next;
        end loop;
end;
$$;

DROP FUNCTION if EXISTS get_spots_in_square(integer, numeric, numeric);
create or replace function get_spots_in_square(radius integer,
                                               r_lat numeric(10, 6),
                                               r_long numeric(10, 6))
    returns table
            (
                spot_name     varchar,
                spot_phone    varchar,
                spot_domain   varchar,
                spot_lat      numeric(10, 6),
                spot_long     numeric(10, 6),
                spot_distance integer
            )
    language plpgsql
as
$$
declare
    var_r record;
begin
    for var_r in (select *
                  from spots a
                  WHERE (
                            SELECT ST_Contains(ST_MakePolygon(ST_MakeLine(ARRAY [
                                ST_Project(ST_Point(r_long, r_lat), radius * SQRT(2), radians(315.0)),
                                ST_Project(ST_Point(r_long, r_lat), radius * SQRT(2), radians(45.0)),
                                ST_Project(ST_Point(r_long, r_lat), radius * SQRT(2), radians(135.0)),
                                ST_Project(ST_Point(r_long, r_lat), radius * SQRT(2), radians(225.0)),
                                ST_Project(ST_Point(r_long, r_lat), radius * SQRT(2), radians(315.0))]::geometry[])),
                                               a.geolocation::geometry))
    )
        loop
            if var_r.phone IS NOT NULL THEN
                spot_distance := ST_Distance(var_r.geolocation, point(r_long, r_lat)::geometry)::INTEGER / 2;
            else
                spot_distance := ST_Distance(var_r.geolocation, point(r_long, r_lat)::geometry)::INTEGER;
            end if;
            spot_name := var_r.name;
            spot_phone = var_r.phone;
            spot_domain = var_r.domain;
            spot_lat = var_r.lat;
            spot_long = var_r.long;
            return next;
        end loop;
end;
$$;
