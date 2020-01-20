# TLC NYC

# PostgreSQL solution
First, I needed to create a database in which I could store tables with TLC NYC data.
```sql
CREATE DATABASE "NYC_TLC"
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    CONNECTION LIMIT = -1;
```
I used this code to create the 2 following tables:
- green_tripdata_2014-07
```sql
CREATE TABLE public.green_tripdata_2014_07
(
    vendor_id VARCHAR(16),
    pickup_datetime TIMESTAMP,
    dropoff_datetime TIMESTAMP,
    Store_and_fwd_flag VARCHAR,
    RateCodeID INTEGER,
    Pickup_longitude FLOAT,
    Pickup_latitude FLOAT,
    Dropoff_longitude FLOAT,
    Dropoff_latitude FLOAT,
    Passenger_count INTEGER,
    Trip_distance FLOAT,
    Fare_amount FLOAT,
    Extra FLOAT,
    MTA_tax FLOAT,
    Tip_amount FLOAT,
    Tolls_amount FLOAT,
    Ehail_fee FLOAT,
    Total_amount FLOAT,
    Payment_type INTEGER,
    Trip_type INTEGER
)
WITH (
    OIDS = FALSE
);

ALTER TABLE public.green_tripdata_2014_07
    OWNER to postgres;
```
- yellow_tripdata_2014-07
```sql
... pretty much the same as above.
```

#### At this point I had to clean the dataset a little bit.

##### Problem:

- Not able to import this data to a PostgreSQL database, because of the following error:
> ERROR:  extra data after last expected column
>
> CONTEXT:  COPY green_tripdata_2014_07, line 1: "2,2014-07-01 00:00:00,2014-07-01 22:33:05,N,1,0,0,-73.952804565429687,40.799091339111328,1,.76,4.5,0..."


##### Solution:
- I found out that each line of the CSV file had a double comma at the end of line - PostgreSQL was interpreting it as additional fields with data
- I wrote a small Python Script that would remove the double comma at the end of the line: taxi_cleaner.py

Before I ran the script I deleted the header and 2 first empty lines in the file manually using Sublime Text. 

Full version of the script available in files.
```python
with open(source_file, "r") as green_taxi_file, \
            open(destination_file, "a") as green_taxi_file_cleaned:
    for line in green_taxi_file.readlines():
        line_with_commas_removed = line[:-3]+'\n'
        green_taxi_file_cleaned.write(line_with_commas_removed)
```

Using the query below I uploaded the new cleaned csv file to my PostgreSQL database.

```sql
COPY public.green_tripdata_2014_07(
	VendorID,
    lpep_pickup_datetime,
    Lpep_dropoff_datetime,
    Store_and_fwd_flag,
    RateCodeID,
    Pickup_longitude,
    Pickup_latitude,
    Dropoff_longitude,
    Dropoff_latitude,
    Passenger_count,
    Trip_distance,
    Fare_amount,
    Extra,
    MTA_tax,
    Tip_amount,
    Tolls_amount,
    Ehail_fee,
    Total_amount,
    Payment_type,
    Trip_type
)
FROM 'C:\Users\blaze\Desktop\TLC_NYC\green_tripdata_2014-07_cleaned.csv' 
DELIMITER ',' 
CSV;
```

# BigQuery

# Python