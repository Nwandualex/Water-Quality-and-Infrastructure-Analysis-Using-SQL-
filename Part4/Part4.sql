-- joining the location table to the visits table

SELECT 
    location.province_name, location.town_name, visits.visit_count, visits.location_id
FROM
    location
JOIN
    visits 
ON
	location.location_id = visits.location_id;
    
-- Now joining the water_source table

SELECT 
    location.province_name, location.town_name, visits.visit_count, visits.location_id,
    water_source.type_of_water_source, water_source.number_of_people_served
FROM
    location
JOIN
    visits 
ON
	location.location_id = visits.location_id
JOIN
	water_source
ON
	visits.source_id=water_source.source_id;
    
/*Note that there are rows where visit_count > 1. These were the sites 
our surveyors collected additional information for, but they happened at the
same source/location. so we need to add a "where" clause where the visit count is 1*/


SELECT 
    location.province_name, location.town_name, visits.visit_count, visits.location_id,
    water_source.type_of_water_source, water_source.number_of_people_served
FROM
    location
JOIN
    visits 
ON
	location.location_id = visits.location_id
JOIN
	water_source
ON
	visits.source_id=water_source.source_id
WHERE visits.visit_count = 1;

/*Now we remove the location_id and visit_count columns, 
and add the location_type column from location and time_in_queue from visits to our results set */


SELECT 
    location.province_name, location.town_name,
    water_source.type_of_water_source, location.location_type,
    water_source.number_of_people_served, visits.time_in_queue
FROM
    location
JOIN
    visits 
ON
	location.location_id = visits.location_id
JOIN
	water_source
ON
	visits.source_id=water_source.source_id
WHERE visits.visit_count = 1;

-- This table assembles data from different tables into one to simplify analysis

SELECT
water_source.type_of_water_source,
location.town_name,
location.province_name,
location.location_type,
water_source.number_of_people_served,
visits.time_in_queue,
well_pollution.results
FROM
visits
LEFT JOIN
well_pollution
ON well_pollution.source_id = visits.source_id
INNER JOIN
location
ON location.location_id = visits.location_id
INNER JOIN
water_source
ON water_source.source_id = visits.source_id
WHERE
visits.visit_count = 1;

-- to make this assembled table above a VIEW

CREATE VIEW combined_analysis_table AS
-- This view assembles data from different tables into one to simplify analysis
SELECT
water_source.type_of_water_source AS source_type,
location.town_name,
location.province_name,
location.location_type,
water_source.number_of_people_served AS people_served,
visits.time_in_queue,
well_pollution.results
FROM
visits
LEFT JOIN
well_pollution
ON well_pollution.source_id = visits.source_id
INNER JOIN
location
ON location.location_id = visits.location_id
INNER JOIN
water_source
ON water_source.source_id = visits.source_id
WHERE
visits.visit_count = 1;

/* We're building another pivot table! This time, we want to break down 
our data into provinces or towns and source types. If we understand where
the problems are, and what we need to improve at those locations, 
we can make an informed decision on where to send our repair teams.*/

WITH province_totals AS (-- This CTE calculates the population of each province
SELECT
province_name,
SUM(people_served) AS total_ppl_serv
FROM
combined_analysis_table
GROUP BY
province_name
)
SELECT
ct.province_name,
-- These case statements create columns for each type of source.
-- The results are aggregated and percentages are calculated
ROUND((SUM(CASE WHEN source_type = 'river'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS river,
ROUND((SUM(CASE WHEN source_type = 'shared_tap'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS shared_tap,
ROUND((SUM(CASE WHEN source_type = 'tap_in_home'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home,
ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home_broken,
ROUND((SUM(CASE WHEN source_type = 'well'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS well
FROM
combined_analysis_table ct
JOIN
province_totals pt ON ct.province_name = pt.province_name
GROUP BY
ct.province_name
ORDER BY
ct.province_name;

-- To get a table of province names and summed up populations for each province.

WITH province_totals AS (-- This CTE calculates the population of each province
SELECT
province_name,
SUM(people_served) AS total_ppl_serv
FROM
combined_analysis_table
GROUP BY
province_name
)
SELECT * FROM province_totals;

-- Let's aggregate the data per town now

WITH town_totals AS (-- −− This CTE calculates the population of each town
-- −− Since there are two Harare towns, we have to group by province_name and town_name
SELECT province_name, town_name, SUM(people_served) AS total_ppl_serv
FROM combined_analysis_table
GROUP BY province_name,town_name
)
SELECT
ct.province_name,
ct.town_name,
ROUND((SUM(CASE WHEN source_type = 'river'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,
ROUND((SUM(CASE WHEN source_type = 'shared_tap'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,
ROUND((SUM(CASE WHEN source_type = 'tap_in_home'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,
ROUND((SUM(CASE WHEN source_type = 'well'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
FROM
combined_analysis_table ct
JOIN -- −− Since the town names are not unique, we have to join on a composite key
town_totals tt ON ct.province_name = tt.province_name AND ct.town_name = tt.town_name
GROUP BY -- −− We group by province first, then by town.
ct.province_name,
ct.town_name
ORDER BY
ct.town_name;

-- making the above query a temporary table

CREATE TEMPORARY TABLE town_aggregated_water_access
WITH town_totals AS (-- −− This CTE calculates the population of each town
-- −− Since there are two Harare towns, we have to group by province_name and town_name
SELECT province_name, town_name, SUM(people_served) AS total_ppl_serv
FROM combined_analysis_table
GROUP BY province_name,town_name
)
SELECT
ct.province_name,
ct.town_name,
ROUND((SUM(CASE WHEN source_type = 'river'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,
ROUND((SUM(CASE WHEN source_type = 'shared_tap'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,
ROUND((SUM(CASE WHEN source_type = 'tap_in_home'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,
ROUND((SUM(CASE WHEN source_type = 'well'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
FROM
combined_analysis_table ct
JOIN -- −− Since the town names are not unique, we have to join on a composite key
town_totals tt ON ct.province_name = tt.province_name AND ct.town_name = tt.town_name
GROUP BY -- −− We group by province first, then by town.
ct.province_name,
ct.town_name
ORDER BY
ct.town_name;

SELECT * FROM town_aggregated_water_access;

-- ordering the river column in descending order
SELECT * FROM town_aggregated_water_access
ORDER BY river DESC;

/* From the above query, we can see that people are drinking river water in Sokoto.
But also looking at the tap_in_home percentages in Sokoto, while some of the citizens are 
forced to drink unsafe water from a river, a lot of people have running water 
in their homes in Sokoto. Large disparities in water access like this often show that 
the wealth distribution in Sokoto is very un-equal. This should be mentioned in the report. 
It should also be recommended that drilling teams be sent to Sokoto first to drill some wells 
for the people who are drinking river water, specifically the rural parts and the city of Bahari. */

-- ordering the province_name column in descending order
SELECT * FROM town_aggregated_water_access
ORDER BY province_name;

/* looking at the data for Amina in Amanzi, it is observed that only 3% of Amina's citizens have 
access to running tap water in their homes. More than half of the people in Amina have taps 
installed in their homes, but they are not working. It should be recommended that teams be sent 
outto go and fix the infrastructure in Amina first. Fixing taps in people's homes, means those 
people don't have to queue for water anymore, so the queues in Amina will also get shorter! */


-- checking which town has the highest ratio of people who have taps, but have no running water?
SELECT
province_name,
town_name,
ROUND(tap_in_home_broken / (tap_in_home_broken + tap_in_home) *
100,0) AS Pct_broken_taps
FROM
town_aggregated_water_access; -- We can see that Amina has infrastructure installed, but almost none of it is working

/* SUMMARY REPORT

Insights
Ok, so let's sum up the data we have.
1. Most water sources are rural in Maji Ndogo.
2. 43% of our people are using shared taps. 2000 people often share one tap.
3. 31% of our population has water infrastructure in their homes, but within that group,
4. 45% face non-functional systems due to issues with pipes, pumps, and reservoirs. Towns like Amina, the rural parts of Amanzi, and a couple
of towns across Akatsi and Hawassa have broken infrastructure.
5. 18% of our people are using wells of which, but within that, only 28% are clean. These are mostly in Hawassa, Kilimani and Akatsi.
6. Our citizens often face long wait times for water, averaging more than 120 minutes:
• Queues are very long on Saturdays.
• Queues are longer in the mornings and evenings.
• Wednesdays and Sundays have the shortest queues. */


/* Our final goal is to implement our plan in the database.
The plan is to improve the water access in Maji Ndogo, so we need to create a table where our 
teams have the information they need to fix, upgrade and repair water sources. They will need 
the addresses of the places they should visit (street address, town, province), the type of water 
source they should improve, and what should be done to improve it. A space for them in the 
database should be included for them to give an update us on their progress. We need to know if the repair is complete, and the date it was
completed, and give them space to upgrade the sources. Let's call this table Project_progress. */


-- creating our project progress table
CREATE TABLE Project_progress (
Project_id SERIAL PRIMARY KEY,
source_id VARCHAR(20) NOT NULL REFERENCES water_source(source_id) ON DELETE CASCADE ON UPDATE CASCADE,
Address VARCHAR(50),
Town VARCHAR(30),
Province VARCHAR(30),
Source_type VARCHAR(50),
Improvement VARCHAR(50),
Source_status VARCHAR(50) DEFAULT 'Backlog' CHECK (Source_status IN ('Backlog', 'In progress', 'Complete')),
Date_of_completion DATE,
Comments TEXT
);

-- Project_progress_query
/*First things first, let's filter the data to only contain sources we want to improve by thinking through the logic first.
1. Only records with visit_count = 1 are allowed.
2. Any of the following rows can be included:
a. Where shared taps have queue times over 30 min.
b. Only wells that are contaminated are allowed -- So we exclude wells that are Clean
c. Include any river and tap_in_home_broken sources. */
SELECT
location.address,
location.town_name,
location.province_name,
water_source.source_id,
water_source.type_of_water_source,
well_pollution.results
FROM
water_source
LEFT JOIN
well_pollution ON water_source.source_id = well_pollution.source_id
INNER JOIN
visits ON water_source.source_id = visits.source_id
INNER JOIN
location ON location.location_id = visits.location_id
WHERE visits.visit_count = 1
AND (results != 'Clean' 
OR type_of_water_source IN ('tap_in_home_broken', 'river')
OR (type_of_water_source = 'shared_tap' AND (time_in_queue >= 30))
)
;

/* we need to add various case statements that will help out the 
engineers in carrying out their tasks*/
SELECT 
    location.address,
    location.town_name,
    location.province_name,
    water_source.source_id,
    water_source.type_of_water_source,
    results,
    CASE
        WHEN results = 'Contaminated: Biological' THEN 'Install UV filter'
        WHEN results = 'Contaminated: Chemical' THEN 'Install RO filter'
        WHEN type_of_water_source = 'river' THEN 'Drill Well'
        WHEN type_of_water_source = 'shared_tap' AND (time_in_queue >= 30) 
        THEN IF (FLOOR(time_in_queue/30)= 1,'Install 1 tap nearby',
        CONCAT('Install ', FLOOR(time_in_queue/30), ' taps nearby'))
 WHEN type_of_water_source = 'tap_in_home_broken' THEN 'Diagnose local infrastructure'
        ELSE NULL
    END AS Improvement
FROM
    water_source
        LEFT JOIN
    well_pollution ON water_source.source_id = well_pollution.source_id
        INNER JOIN
    visits ON water_source.source_id = visits.source_id
        INNER JOIN
    location ON location.location_id = visits.location_id
WHERE
    visits.visit_count = 1
        AND (results != 'Clean'
        OR type_of_water_source IN ('tap_in_home_broken' , 'river')
        OR (type_of_water_source = 'shared_tap'
        AND (time_in_queue >= 30)));
        
        
/* Now that we have the data we want to provide to engineers, we need to 
populate the Project_progress table with the results of our query. */

-- first we put the query in a temporary table
CREATE TEMPORARY TABLE Project_report AS
SELECT 
    location.address AS Address,
    location.town_name AS Town,
    location.province_name AS Province,
    water_source.source_id,
    water_source.type_of_water_source AS Source_type,
    results,
    CASE
        WHEN results = 'Contaminated: Biological' THEN 'Install UV filter'
        WHEN results = 'Contaminated: Chemical' THEN 'Install RO filter'
        WHEN type_of_water_source = 'river' THEN 'Drill Well'
WHEN type_of_water_source = 'shared_tap' AND (time_in_queue >= 30) 
        THEN IF (FLOOR(time_in_queue/30)= 1,'Install 1 tap nearby',
        CONCAT('Install ', FLOOR(time_in_queue/30), ' taps nearby'))
        WHEN type_of_water_source = 'tap_in_home_broken' THEN 'Diagnose local infrastructure'
        ELSE NULL
    END AS Improvement
FROM
    water_source
        LEFT JOIN
    well_pollution ON water_source.source_id = well_pollution.source_id
        INNER JOIN
    visits ON water_source.source_id = visits.source_id
        INNER JOIN
    location ON location.location_id = visits.location_id
WHERE
    visits.visit_count = 1
        AND (results != 'Clean'
        OR type_of_water_source IN ('tap_in_home_broken' , 'river')
        OR (type_of_water_source = 'shared_tap'
        AND (time_in_queue >= 30)));

-- Now we Insert into project progress
INSERT INTO project_progress(source_id, Address, Town, Province, Source_type, Improvement)
SELECT source_id, Address, Town, Province, Source_type, Improvement
FROM project_report;

SELECT * FROM project_progress; -- checking the contents of the project progress table after populating it
  