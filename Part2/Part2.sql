SET SQL_SAFE_UPDATES=0;

UPDATE employee 
SET 
    email = CONCAT(LOWER(REPLACE(employee_name, ' ', '.')),
            '@ndogowater.gov'); -- This updates the email column with the concatenation of the employee_name column and a string which we specified
            
SELECT 
    LENGTH(phone_number)
FROM
    employee; -- checking the length of the strings in the phone_number column
    
UPDATE employee 
SET 
    phone_number = TRIM(phone_number); -- updating the phone_number column with the trimmed version of it
    
SELECT town_name,
    COUNT(town_name) num_employees
FROM
    employee
GROUP BY town_name; -- checking how many of the employees stay in each town

SELECT 
    assigned_employee_id, COUNT(visit_count) AS number_of_visits
FROM
    visits
GROUP BY assigned_employee_id ORDER BY number_of_visits DESC; -- checking the number of visits each employee did and ordering it from the highest

SELECT 
    employee_name, email, phone_number
FROM
    employee
WHERE
    assigned_employee_id IN (1 , 30, 34); -- fetching the name, email and phone no. of the employees with the highest no. of visits using the IDs(based on the last query)

SELECT 
    town_name, COUNT(town_name) AS records_per_town
FROM
    location
GROUP BY town_name ORDER BY records_per_town DESC; -- checking the number of records per town

SELECT 
    province_name, COUNT(province_name) AS records_per_province
FROM
    location
GROUP BY province_name ORDER BY records_per_province DESC; -- checking the number of records per province

SELECT 
    province_name,
    town_name,
    COUNT(town_name) AS records_per_town
FROM
    location
GROUP BY province_name , town_name ORDER BY province_name,records_per_town DESC; -- checking the number of records per town, grouping by province and town name

SELECT 
    location_type, COUNT(location_type) AS num_sources
FROM
    location
GROUP BY location_type; -- checking the number of records per location type

SELECT 
    type_of_water_source, COUNT(type_of_water_source) number_of_sources
FROM
    water_source
GROUP BY type_of_water_source; -- checking to know how many of each of the different water source type there is

SELECT 
    type_of_water_source, ROUND(AVG(number_of_people_served)) Ave_people_per_source
FROM
    water_source
GROUP BY type_of_water_source; -- checking to know the average number of people served by each water source

SELECT 
    type_of_water_source,
    SUM(number_of_people_served) population_served
FROM
    water_source
GROUP BY type_of_water_source
ORDER BY population_served DESC; -- checking to know the total number of people served by each type of water source in total

SELECT 
    type_of_water_source, ROUND(((SUM(number_of_people_served))/27628140)*100,0) percentage_people_per_source
FROM
    water_source
GROUP BY type_of_water_source
ORDER BY SUM(number_of_people_served) DESC; -- checking to know the percentage of the number of people served per source


SELECT 
    type_of_water_source,
    SUM(number_of_people_served) AS population_served,
RANK() OVER(
ORDER BY SUM(number_of_people_served) DESC
) AS rank_by_population
FROM
    water_source
WHERE type_of_water_source IN ("river","tap_in_home_broken","well","shared_tap")
GROUP BY type_of_water_source; -- ranking the population_served column, excluding the tap_in_home

SELECT 
    source_id, type_of_water_source, number_of_people_served,
RANK() OVER(
PARTITION BY type_of_water_source
ORDER BY number_of_people_served DESC
) AS rank_by_population
FROM
    water_source; -- query to know which particular type_of_water source to be fixed first, based on the number_of_people_served
    
SELECT 
    DATEDIFF(MAX(time_of_record),MIN(time_of_record)) diff_in_time
FROM
    visits; -- query to know how long the survey took
    
SELECT 
    AVG(NULLIF(time_in_queue,0))-- used the NULLIF function because some values(which are for tap_in_home have a value of 0, which means there is no queue time)
FROM
    visits; -- calculating the average queue time

 SELECT 
    DAYNAME(time_of_record) day_of_week,
    ROUND(AVG(NULLIF(time_in_queue,0))) average_queue_time
FROM
    visits
GROUP BY day_of_week; -- checking the average queue time per day of the week


 SELECT 
    TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
    ROUND(AVG(NULLIF(time_in_queue,0))) average_queue_time
FROM
    visits
GROUP BY hour_of_day
ORDER BY hour_of_day; -- checking the average queue time per hour of the day


SELECT
TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
-- Sunday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue
ELSE NULL
END
),0) AS Sunday,
-- Monday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Monday' THEN time_in_queue
ELSE NULL
END
),0) AS Monday,
-- Tuesday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Tuesday' THEN time_in_queue
ELSE NULL
END
),0) AS Tuesday,
-- Wednesday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Wednesday' THEN time_in_queue
ELSE NULL
END
),0) AS Wednesday,
-- Thursday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Thursday' THEN time_in_queue
ELSE NULL
END
),0) AS Thursday,
-- Friday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Friday' THEN time_in_queue
ELSE NULL
END
),0) AS Friday,
-- Saturday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Saturday' THEN time_in_queue
ELSE NULL
END
),0) AS Saturday
FROM
visits
WHERE
time_in_queue != 0 -- this excludes other sources with 0 queue times
GROUP BY
hour_of_day
ORDER BY
hour_of_day;  -- breaking down the queues for each hour for each day

/** Water Accessibility and infrastructure summary report

 This survey aimed to identify the water sources people use and determine both the total and average number of users for each source.
 Additionally, it examined the duration citizens typically spend in queues to access water.
 
 Insights
1. Most water sources are rural.
2. 43% of our people are using shared taps. 2000 people often share one tap.
3. 31% of our population has water infrastructure in their homes, but within that group, 45% face non-functional systems due to issues with pipes,
pumps, and reservoirs.
4. 18% of our people are using wells of which, but within that, only 28% are clean..
5. Our citizens often face long wait times for water, averaging more than 120 minutes.
6. In terms of queues:
- Queues are very long on Saturdays.
- Queues are longer in the mornings and evenings.
- Wednesdays and Sundays have the shortest queues. **/
