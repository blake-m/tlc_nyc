/*
This script answers the following question:
- How were cash and credit card payments developing in 2014 (here: july)?

Fields I use:
	pickup_datetime - I will consider it as the time of a trip
	total_amount - it includes all payment and additional fees

NOTE: I subtract tip_amount from total_amount where payment is not cash, as cash tips
are not included in this dataset and looking at them might give misleading results.

payment_type - according to the dictionary from the Google cloud:
A numeric code signifying how the passenger paid for the trip.
	1= Credit card
	2= Cash
	3= No charge
	4= Dispute
	5= Unknown
	6= Voided trip
*/

-- Aggregate counts/amounts sums of payments by days of years
WITH payments_all AS (
    SELECT
        'yellow' AS which_table,
        pickup_datetime,
        CASE
            WHEN payment_type = 'CRD' THEN 1
            WHEN payment_type = 'CSH' THEN 2
            WHEN payment_type = 'NOC' THEN 3
            WHEN payment_type = 'DIS' THEN 4
            WHEN payment_type = 'UNK' THEN 5
        END AS payment_type,
        total_amount - tip_amount AS total_minus_tip
    FROM `bigquery-public-data.new_york.tlc_yellow_trips_2014`
    WHERE payment_type IN ('CRD', 'CSH')

    UNION ALL

    SELECT
        'green' AS which_table,
        pickup_datetime AS pickup_datetime,
        payment_type,
        total_amount - tip_amount AS total_minus_tip
    FROM `bigquery-public-data.new_york.tlc_green_trips_2014`
    WHERE payment_type IN (1, 2)
)

SELECT
	payment_type,
	EXTRACT(DAYOFYEAR FROM pickup_datetime) AS day_of_year,
	COUNT(total_minus_tip) AS count_of_transactions,
	SUM(total_minus_tip) AS transaction_amounts_sum
FROM payments_all
GROUP BY payment_type, day_of_year
ORDER BY payment_type, day_of_year
;

-- Aggregate counts/amounts sums of payments by days of years
WITH payments_all AS (
    SELECT
        'yellow' AS which_table,
        pickup_datetime,
        CASE
            WHEN payment_type = 'CRD' THEN 1
            WHEN payment_type = 'CSH' THEN 2
            WHEN payment_type = 'NOC' THEN 3
            WHEN payment_type = 'DIS' THEN 4
            WHEN payment_type = 'UNK' THEN 5
        END AS payment_type,
        total_amount - tip_amount AS total_minus_tip
    FROM `bigquery-public-data.new_york.tlc_yellow_trips_2014`
    WHERE payment_type IN ('CRD', 'CSH')

    UNION ALL

    SELECT
        'green' AS which_table,
        pickup_datetime AS pickup_datetime,
        payment_type,
        total_amount - tip_amount AS total_minus_tip
    FROM `bigquery-public-data.new_york.tlc_green_trips_2014`
    WHERE payment_type IN (1, 2)
)

SELECT
	payment_type,
	EXTRACT(MONTH FROM pickup_datetime) AS month_,
	COUNT(total_minus_tip) AS count_of_transactions,
	SUM(total_minus_tip) AS transaction_amounts_sum
FROM payments_all
GROUP BY payment_type, month_
ORDER BY payment_type, month_
;