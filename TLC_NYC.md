# TLC NYC

1. PostgreSQL (July 2014 only)
2. BigQuery (Whole 2014)

# PostgreSQL solutions
###### Based on July 2014 only due to my computer's limitations.
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
- I wrote a small Python Script that would remove the double comma at the end of the line: **taxi_cleaner.py**

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

### Question 1 - Which day of week had the highest count of rides in 2014?
Code in the following file:     
- postgresql/Question1_postgresql_answer.sql   

Visualisations in the following file:    
- python_scripts/Question1_postgresql_based_visualisations-checkpoint.ipynb

##### Answer:
Thursday was the day with the highest count of rides in July 2014:
- All cabs: 2451073	
- Green cabs only: 205274
- Yellow cabs only: 2245799


### Question 2 - How were cash and credit card payments developing in 2014?
Code in the following file:     
- postgresql/Question2_postgresql_answer.sql   

Visualisations in the following file:    
- python_scripts/Question2_postgresql_based_visualisations-checkpoint.ipynb


### Question 3 - What is the most popular pick-up point in New York in 2014?
Code in the following file:     
- postgresql/Question3_postgresql_answer.sql   

Visualisations in the following file:    
- python_scripts/Question3_postgresql_based_visualisations-checkpoint.ipynb

Each degree of latitude is approximately 111 kilometers apart. It is constant.
Longitude changes but around New York 1 degree is around 85 km. I don't need exact
numbers for this exercise. I will be using squares of 1/10000 of degrees which will
correspond to rectangles of around 11 x 8.5 meters. This way I found the most
popular 'pickup-rectangle' (The same answer was found in BigQuery Solution): 
- pickup_longitude: -73.9941
- pickup_latitude: 40.7512
- popularity (how many pickups from this rectangle): 7747

When you find this rectangle on a map, you'll see that it's 
**right outside of Pensylvania Station**.

# BigQuery

### Question 1 - Which day of week had the highest count of rides in 2014?
Code in the following file:     
- google_cloud/Question1_google_cloud_answer.sql   

Visualisations in the following file:    
- python_scripts/Question1_google_cloud_based_visualisations-checkpoint.ipynb

##### Answer
Sunday was the day with the highest count of rides in 2014:
- All cabs: 28281604		
- Green cabs only: 2886558
- Yellow cabs only: 25395046


### Question 2 - How were cash and credit card payments developing in 2014?
Code in the following file:     
- google_cloud/Question2_google_cloud_answer.sql   

Visualisations in the following file:    
- python_scripts/Question2_google_cloud_based_visualisations-checkpoint.ipynb


### Question 3 - What is the most popular pick-up point in New York in 2014?
Code in the following file:     
- google_cloud/Question3_google_cloud_answer.sql   

Visualisations in the following file:    
- python_scripts/Question3_google_cloud_based_visualisations-checkpoint.ipynb


##### Answer   
Each degree of latitude is approximately 111 kilometers apart. It is constant.
Longitude changes but around New York 1 degree is around 85 km. I don't need exact
numbers for this exercise. I will be using squares of 1/10000 of degrees which will
correspond to rectangles of around 11 x 8.5 meters. This way I found the most
popular 'pickup-rectangle':
- pickup_longitude: -73.9941
- pickup_latitude: 40.7512
- popularity (how many pickups from this rectangle): 93396

When you find this rectangle on a map, you'll see that it's 
**right outside of Pensylvania Station**.
	



Projecting it onto a map can confirm, whether less popular rectangles don't form bigger,
more popular pick-up locations.