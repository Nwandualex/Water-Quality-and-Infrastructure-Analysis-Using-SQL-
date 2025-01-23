SHOW TABLES;
SELECT 
    *
FROM
    location
LIMIT 5; -- inspecting the first 5 rows of the location table

SELECT 
    *
FROM
    visits
LIMIT 5; -- inspecting the first 5 rows of the visits table

SELECT 
    *
FROM
    water_source
LIMIT 5; -- inspecting the first 5 rows of the water_source table

SELECT DISTINCT
    type_of_water_source
FROM
    water_source; -- fetching the unique water sources
    
SELECT 
    *
FROM
    visits
WHERE
    time_in_queue > 500; -- checking the visits table for when time in queue is greater than 500 mins
    
SELECT 
    *
FROM
    water_source
WHERE
    source_id IN ("AkKi00881224","AkLu01628224","AkRu05234224","HaRu19601224","HaZa21742224","SoRu36096224","SoRu37635224","SoRu38776224"); -- using some of the source IDs to check the water sources with high queue times 

SELECT 
    *
FROM
    water_quality
WHERE
    subjective_quality_score = 10 AND visit_count=2; -- finding records where quality score is 10 and was visited twice

SELECT 
    *
FROM
    well_pollution
LIMIT 5; -- investigating the pollution table

SELECT 
    *
FROM
    well_pollution
WHERE
    results = 'Clean' AND biological > 0.01; -- checking for sources that were registered as clean but have a biological result of greater than 0.01, because this is an error
    
SELECT * FROM well_pollution WHERE description LIKE "Clean%" AND biological>0.01; -- checking the sources with errors

UPDATE
well_pollution
SET
description = 'Bacteria: E. coli'
WHERE
description = 'Clean Bacteria: E. coli'; -- setting the correct description column

UPDATE
well_pollution
SET
description = "Bacteria: Giardia Lamblia"
WHERE
description = 'Clean Bacteria: Giardia Lamblia'; -- setting the correct description column

UPDATE
well_pollution
SET
results = 'Contaminated: Biological'
WHERE
biological > 0.01 AND results = 'Clean'; -- setting the correct results column

SELECT
*
FROM
well_pollution
WHERE
description LIKE "Clean_%"
OR (results = "Clean" AND biological > 0.01);