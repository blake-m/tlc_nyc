"""This script takes a specified CSV file with data about NYC taxi rides
and removes 2 commas from the end of each line. Returns a new CSV file with
'_cleaned' appended to the name of source file.
"""

GREEN_TAXI_PATH = r"C:\Users\blaze\Desktop\TLC_NYC\green_tripdata_2014-07.csv"
GREEN_TAXI_CLEANED_PATH = r"C:\Users\blaze\Desktop\TLC_NYC\green_tripdata_2014-07_cleaned.csv"


def taxi_cleaner(source_file: str, destination_file: str) -> None:
	"""Removes two commas ',,' from the end of each line."""
	with open(source_file, "r") as green_taxi_file, \
				open(destination_file, "a") as green_taxi_file_cleaned:
		for line in green_taxi_file.readlines():
			line_with_commas_removed = line[:-3]+'\n'
			green_taxi_file_cleaned.write(line_with_commas_removed)


if __name__ == "__main__":
	taxi_cleaner(GREEN_TAXI_PATH, GREEN_TAXI_CLEANED_PATH)
