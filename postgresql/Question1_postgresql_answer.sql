/*
This script answers the following question:
- Which day of week had the highest count of rides in 2014?
    --> here, due to my machine's limitations I take only July into consideration

I could achieve the same by using Common Table Expressions, but since I use it
with my Google Cloud solution I use Temporary Tables here
*/

DROP TABLE IF EXISTS day_of_week_all
;
/* Creates a big table containing date data from different tables

NOTE:
    If the ride starts on Monday and ends on Tuesday it wil be considered a Monday ride.
    Therefore pickup_datetime will be considered.
*/
CREATE TEMP TABLE day_of_week_all AS
SELECT
	'green' AS which_table,
	EXTRACT(DOW FROM lpep_pickup_datetime) AS day_of_week
FROM green_tripdata_2014_07

UNION ALL

SELECT
	'yellow' AS which_table,
	EXTRACT(DOW FROM pickup_datetime) AS day_of_week
FROM yellow_tripdata_2014_07;





DROP TABLE IF EXISTS day_of_week_all_count
;
-- Aggregates data by day_of_week for: all data; yellow cabs only; green cabs only;
CREATE TEMP TABLE day_of_week_all_count AS
SELECT
	CASE
		WHEN day_of_week = 0 THEN 'Sunday'
		WHEN day_of_week = 1 THEN 'Monday'
		WHEN day_of_week = 2 THEN 'Tuesday'
		WHEN day_of_week = 3 THEN 'Wednesday'
		WHEN day_of_week = 4 THEN 'Thursday'
		WHEN day_of_week = 5 THEN 'Friday'
		WHEN day_of_week = 6 THEN 'Saturday'
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
ORDER BY day_of_week
;



-- Exports data to a csv file
COPY day_of_week_all_count
TO 'C:\Users\blaze\Desktop\TLC_NYC\result_csv_for_tableau\day_of_week_counts.csv'
DELIMITER ',' CSV HEADER
;
