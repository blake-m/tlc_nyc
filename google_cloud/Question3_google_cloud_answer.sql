/*
This script answers the following question:
- What is the most popular pick-up point in New York in 2014?

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

WITH most_popular_pickup_locations AS (
    WITH strings AS (
        WITH pickups_all AS (
            -- creates a big dataset from 2 smaller ones,
            -- converts data type to rounded numeric,
            -- leaves only required variables
            SELECT
                'yellow' AS which_table,
                ROUND(pickup_longitude, 4) AS pickup_longitude,
                ROUND(pickup_latitude, 4) AS pickup_latitude
            FROM `bigquery-public-data.new_york.tlc_yellow_trips_2014`

            UNION ALL

            SELECT
                'green' AS which_table,
                ROUND(pickup_longitude, 4) AS pickup_longitude,
                ROUND(pickup_latitude, 4) AS pickup_latitude
            FROM `bigquery-public-data.new_york.tlc_green_trips_2014`
        )
        -- Converts latitude/longitude to one variable 'above-mentioned 11 x 8.5 meters rectangles'
        SELECT
            which_table,
            CONCAT(RPAD(SUBSTR(CAST(pickup_longitude AS STRING), 1, 8), 8, '0'),
                   RPAD(SUBSTR(CAST(pickup_latitude AS STRING), 1, 7), 7, '0')) AS joint_pickup
        FROM pickups_all
        WHERE pickup_longitude != 0 OR pickup_latitude != 0
    )
    -- groups by this variable
    SELECT
        joint_pickup,
        COUNT(joint_pickup) AS popularity
    FROM strings
    GROUP BY joint_pickup
    ORDER BY COUNT(joint_pickup) DESC
)
-- Recreates initial rounded longitudes/latitudes from 'above-mentioned 11 x 8.5 meters rectangles'
-- It will serve better for visualisation purposes
SELECT
	CAST(SUBSTR(joint_pickup, 1, 8) AS FLOAT64) AS pickup_longitude,
	CAST(SUBSTR(joint_pickup,9, 7) AS FLOAT64) AS pickup_latitude,
	popularity
FROM most_popular_pickup_locations;