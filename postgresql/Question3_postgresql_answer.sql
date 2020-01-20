/*
This script answers the following question:
- What is the most popular pick-up point in New York in 2014 (here - July)?

Each degree of latitude is approximately 111 kilometers apart. It is constant.
Longitude changes but around New York it is around 85 km. I don't need exact
numbers for this exercise. I will be using squares of 1/10000 of degrees which will
correspond to rectangles of around 11 x 8.5 meters. This way I will find the most
popular 'pickup-rectangle'. Later I will project it onto a map to confirm, whether
less popular rectangles don't form bigger, more popular pick-up locations.


Clearly, some of the data is broken (like 0.0000 longitudes/latitudes or points
way outside of New York). There's not a big reason to worry about it as the
percentage of broken data is not great and it doesn't influence the outcome really.

NOTE:
- In this data set there's a variable called 'ratecodeid' (The final rate code
in effect at the end of the trip. 1= Standard rate 2=JFK 3=Newark 4=Nassau
or Westchester 5=Negotiated fare 6=Group ride) - I could use it to filter out
airports. I am not sure whether Negotiated Fare and Group Ride could not go
to airport anyway and it will be easy to filter airports out later anyway
so I won't use it.
*/

DROP TABLE IF EXISTS pickups_all
;
-- creates a big dataset from 2 smaller ones,
-- converts data type to rounded numeric,
-- leaves only required variables
CREATE TEMPORARY TABLE pickups_all AS
SELECT
	'yellow' AS which_table,
	ROUND(pickup_longitude::numeric, 4) AS pickup_longitude,
	ROUND(pickup_latitude::numeric, 4) AS pickup_latitude
FROM yellow_tripdata_2014_07

UNION ALL

SELECT
	'green' AS which_table,
	ROUND(pickup_longitude::numeric, 4) AS pickup_longitude,
	ROUND(pickup_latitude::numeric, 4) AS pickup_latitude
FROM green_tripdata_2014_07
;



DROP TABLE IF EXISTS most_popular_pickup_locations;
-- Converts latitude/longitude to one variable 'above-mentioned 11 x 8.5 meters rectangles'
-- groups by it
CREATE TABLE most_popular_pickup_locations AS
WITH strings AS (
	SELECT
		which_table,
		pickup_longitude::varchar(8) || pickup_latitude::varchar(7) AS joint_pickup
	FROM pickups_all
	WHERE pickup_longitude != 0 OR pickup_latitude != 0
)
SELECT
	joint_pickup,
	COUNT(joint_pickup) AS popularity
FROM strings
GROUP BY joint_pickup
ORDER BY COUNT(joint_pickup) DESC
;



DROP TABLE IF EXISTS most_popular_pickup_locations_numeric;
-- Recreates initial rounded longitudes/latitudes from 'above-mentioned 11 x 8.5 meters rectangles'
-- It will serve better for visualisation purposes
CREATE TABLE most_popular_pickup_locations_numeric AS
SELECT
	LEFT(joint_pickup, 8)::numeric AS pickup_longitude,
	RIGHT(joint_pickup, 7)::numeric AS pickup_latitude,
	popularity
FROM most_popular_pickup_locations;

-- exorts the results
COPY most_popular_pickup_locations_numeric
TO 'C:\Users\blaze\Desktop\TLC_NYC\result_csv_for_tableau\most_popular_pickup_locations_light.csv'
DELIMITER ',' CSV HEADER