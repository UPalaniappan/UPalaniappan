# Get the day of month, week number, day of year and day of week from ser.
# ser = pd.Series(['01 Jan 2010', '02-02-2011', '20120303', '2013/04/04', '2014-05-05', '2015-06-06T12:20'])

import pandas as pd

ser = pd.Series(['01 Jan 2010', '02-02-2011', '20120303', '2013/04/04', '2014-05-05', '2015-06-06T12:20'])
# formating to year, month, day order
format_date=pd.to_datetime(ser, infer_datetime_format=True)


# checking if the date format is right
print(format_date)

# get day of the month using dt.day. 
#change the serial to string using tolist() function
#change it to string to print it

day_of_month=format_date.dt.day
print("Date: "+ str(day_of_month.tolist()))


#get week of the year using dt.isocalendar().week

week_number=format_date.dt.isocalendar().week
print("Week number: "+ str(week_number.to_list()))


#get day of the year using dt.day_of_year

day_of_year=format_date.dt.day_of_year
print("Day of year: "+ str(day_of_year.to_list()))


#get name of the day using dt.day_name()

day_of_week=format_date.dt.day_name()
print("Day of week: "+ str(day_of_week.to_list()))
