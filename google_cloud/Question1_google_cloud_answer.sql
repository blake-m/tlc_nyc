/*
This script answers the following question:
- Which day of week had the highest count of rides in 2014?

There are 3 tables available to work with:
- new_york.tlc_green_trips_2014
- new_york.tlc_yellow_trips_2014
- new_york_taxi_trips.tlc_green_trips_2014

I will use the 2 first ones as the third one is the same as the first 1.
*/

/* Creates a big table containing date data from different tables

NOTE:
    If the ride starts on Monday and ends on Tuesday it wil be considered a Monday ride.
    Therefore pickup_datetime will be considered.
*/
WITH day_of_week_all AS (
SELECT
	'green' AS which_table,
	EXTRACT(DAYOFWEEK FROM pickup_datetime) AS day_of_week
FROM `bigquery-public-data.new_york.tlc_green_trips_2014`

UNION ALL

SELECT
	'yellow' AS which_table,
	EXTRACT(DAYOFWEEK FROM pickup_datetime) AS day_of_week
FROM `bigquery-public-data.new_york.tlc_yellow_trips_2014`
)

SELECT
	CASE
		WHEN day_of_week = 1 THEN 'Monday'
		WHEN day_of_week = 2 THEN 'Tuesday'
		WHEN day_of_week = 3 THEN 'Wednesday'
		WHEN day_of_week = 4 THEN 'Thursday'
		WHEN day_of_week = 5 THEN 'Friday'
		WHEN day_of_week = 6 THEN 'Saturday'
    ELSE 'Sunday'
	END						AS day_of_week_word,
	COUNT(day_of_week)  	AS day_of_week_count_all,
	SUM(CASE
		WHEN which_table = 'green' THEN 1 ELSE 0
	    END) 				AS day_of_week_count_green,
	SUM(CASE
		WHEN which_table = 'yellow' THEN 1 ELSE 0
	    END) 				AS day_of_week_count_yellow
FROM day_of_week_all
GROUP BY day_of_week
ORDER BY day_of_week_count_all DESC
;

