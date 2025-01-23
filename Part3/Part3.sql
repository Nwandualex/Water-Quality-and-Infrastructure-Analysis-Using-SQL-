/** we need to integrate an auditor's report, we will need to access many of the tables in the database, so it is important to understand the database structure.
To do this we really need to understand the relationships first, so we know where to pull information from. So we will need to get the ERD for the
md_water_services database **/

USE md_water_services;

DROP TABLE IF EXISTS `auditor_report`;
CREATE TABLE `auditor_report` (
`location_id` VARCHAR(32),
`type_of_water_source` VARCHAR(64),
`true_water_source_score` int DEFAULT NULL,
`statements` VARCHAR(255)
); -- creating a table that we will populate with a CSV file

SELECT 
    location_id, true_water_source_score
FROM
    auditor_report;
    
SELECT 
    auditor_report.location_id AS audit_location,
    auditor_report.true_water_source_score,
    visits.location_id AS visit_location,
	visits.record_id
FROM
    auditor_report
JOIN
	visits
ON
	auditor_report.location_id = visits.location_id; -- joining the auditor_report table and the visits table

SELECT 
    auditor_report.location_id AS audit_location,
    auditor_report.true_water_source_score,
    visits.location_id AS visit_location,
	visits.record_id,
    water_quality.subjective_quality_score
FROM
    auditor_report
JOIN
	visits
ON
	auditor_report.location_id = visits.location_id
JOIN
	water_quality
ON
	visits.record_id=water_quality.record_id; -- joining the subjective_quality_score from the water_quality table
    

SELECT 
    auditor_report.location_id AS location_id,
    visits.record_id,
    auditor_report.true_water_source_score AS auditor_score,
    water_quality.subjective_quality_score AS surveyor_score
FROM
    auditor_report
JOIN
	visits
ON
	auditor_report.location_id = visits.location_id
JOIN
	water_quality
ON
	visits.record_id=water_quality.record_id;   -- dropping one of the location_id columns and renaming some columns 
    

SELECT 
    auditor_report.location_id AS location_id,
    visits.record_id,
    auditor_report.true_water_source_score AS auditor_score,
    water_quality.subjective_quality_score AS surveyor_score
FROM
    auditor_report
JOIN
	visits
ON
	auditor_report.location_id = visits.location_id
JOIN
	water_quality
ON
	visits.record_id=water_quality.record_id
WHERE
	auditor_report.true_water_source_score = water_quality.subjective_quality_score; -- checking for records where the auditor score and the surveyor score are the same
    

SELECT 
    auditor_report.location_id AS location_id,
    visits.record_id,
    auditor_report.true_water_source_score AS auditor_score,
    water_quality.subjective_quality_score AS surveyor_score
FROM
    auditor_report
JOIN
	visits
ON
	auditor_report.location_id = visits.location_id
JOIN
	water_quality
ON
	visits.record_id=water_quality.record_id
WHERE
	visits.visit_count = 1 AND 
    auditor_report.true_water_source_score = water_quality.subjective_quality_score
    ; -- showing only records where auditor report and surveyor report are same and removing duplicated records where site was visited more than once
    

SELECT 
    auditor_report.location_id AS location_id,
    visits.record_id,
    auditor_report.true_water_source_score AS auditor_score,
    water_quality.subjective_quality_score AS surveyor_score
FROM
    auditor_report
JOIN
	visits
ON
	auditor_report.location_id = visits.location_id
JOIN
	water_quality
ON
	visits.record_id=water_quality.record_id
WHERE
	visits.visit_count = 1 AND 
    auditor_report.true_water_source_score != water_quality.subjective_quality_score
    ; -- selecting records where the auditor score and the surveyor score aren't the same
    

SELECT 
    auditor_report.location_id AS location_id,
    auditor_report.type_of_water_source AS auditor_source,
    water_source.type_of_water_source AS surveyor_source,
    visits.record_id,
    auditor_report.true_water_source_score AS auditor_score,
    water_quality.subjective_quality_score AS surveyor_score
FROM
    auditor_report
JOIN
	visits
ON
	auditor_report.location_id = visits.location_id
JOIN
	water_quality
ON
	visits.record_id=water_quality.record_id
JOIN
	water_source
ON visits.source_id=water_source.source_id
WHERE
	visits.visit_count = 1 AND 
    auditor_report.true_water_source_score != water_quality.subjective_quality_score
    ; -- checking to see if the type of water source for the surveyor and auditor's report are the same for cases where the quality score for both the auditor and surveyor aren't the same
    

SELECT 
    auditor_report.location_id AS location_id,
    visits.record_id,
    employee.assigned_employee_id,
    auditor_report.true_water_source_score AS auditor_score,
    water_quality.subjective_quality_score AS surveyor_score
FROM
    auditor_report
JOIN
	visits
ON
	auditor_report.location_id = visits.location_id
JOIN
	water_quality
ON
	visits.record_id=water_quality.record_id
JOIN
	employee
ON
	visits.assigned_employee_id=employee.assigned_employee_id
WHERE
	visits.visit_count = 1 AND 
    auditor_report.true_water_source_score != water_quality.subjective_quality_score
    ; -- adding the employee IDs of the surveyors responsible for the errors in water quality score
    


SELECT 
    auditor_report.location_id AS location_id,
    visits.record_id,
    employee.employee_name,
    auditor_report.true_water_source_score AS auditor_score,
    water_quality.subjective_quality_score AS surveyor_score
FROM
    auditor_report
JOIN
	visits
ON
	auditor_report.location_id = visits.location_id
JOIN
	water_quality
ON
	visits.record_id=water_quality.record_id
JOIN
	employee
ON
	visits.assigned_employee_id=employee.assigned_employee_id
WHERE
	visits.visit_count = 1 AND 
    auditor_report.true_water_source_score != water_quality.subjective_quality_score
    ; -- adding the employee names of the surveyors responsible for the errors in water quality score
    

WITH Incorrect_records AS (
	SELECT 
    auditor_report.location_id AS location_id,
    visits.record_id,
    employee.employee_name,
    auditor_report.true_water_source_score AS auditor_score,
    water_quality.subjective_quality_score AS surveyor_score
FROM
    auditor_report
JOIN
	visits
ON
	auditor_report.location_id = visits.location_id
JOIN
	water_quality
ON
	visits.record_id=water_quality.record_id
JOIN
	employee
ON
	visits.assigned_employee_id=employee.assigned_employee_id
WHERE
	visits.visit_count = 1 AND 
    auditor_report.true_water_source_score != water_quality.subjective_quality_score
    )
    SELECT * FROM Incorrect_records; -- converting our previous query into a CTE
    

WITH Incorrect_records AS (
	SELECT 
    auditor_report.location_id AS location_id,
    visits.record_id,
    employee.employee_name,
    auditor_report.true_water_source_score AS auditor_score,
    water_quality.subjective_quality_score AS surveyor_score
FROM
    auditor_report
JOIN
	visits
ON
	auditor_report.location_id = visits.location_id
JOIN
	water_quality
ON
	visits.record_id=water_quality.record_id
JOIN
	employee
ON
	visits.assigned_employee_id=employee.assigned_employee_id
WHERE
	visits.visit_count = 1 AND 
    auditor_report.true_water_source_score != water_quality.subjective_quality_score
    )
    SELECT DISTINCT employee_name FROM Incorrect_records; -- checking for the unique employee names responsible for the errors
    
  
WITH error_count AS (
SELECT
 employee_name, 
 COUNT(employee_name) AS number_of_mistakes
 FROM(
	SELECT 
    auditor_report.location_id AS location_id,
    visits.record_id,
    employee.employee_name,
    auditor_report.true_water_source_score AS auditor_score,
    water_quality.subjective_quality_score AS surveyor_score
FROM
    auditor_report
JOIN
	visits
ON
	auditor_report.location_id = visits.location_id
JOIN
	water_quality
ON
	visits.record_id=water_quality.record_id
JOIN
	employee
ON
	visits.assigned_employee_id=employee.assigned_employee_id
WHERE
	visits.visit_count = 1 AND 
    auditor_report.true_water_source_score != water_quality.subjective_quality_score
    ) AS incorrect_records
GROUP BY employee_name
ORDER BY number_of_mistakes DESC
)
SELECT *
FROM error_count; -- this query checks the number of errors made by each employee
 
/* from the above query, we can see that some employees 
are making a lot of errors, while others just made a few */


WITH error_count AS (
SELECT
 employee_name, 
 COUNT(employee_name) AS number_of_mistakes
 FROM(
	SELECT 
    auditor_report.location_id AS location_id,
    visits.record_id,
    employee.employee_name,
    auditor_report.true_water_source_score AS auditor_score,
    water_quality.subjective_quality_score AS surveyor_score
FROM
    auditor_report
JOIN
	visits
ON
	auditor_report.location_id = visits.location_id
JOIN
	water_quality
ON
	visits.record_id=water_quality.record_id
JOIN
	employee
ON
	visits.assigned_employee_id=employee.assigned_employee_id
WHERE
	visits.visit_count = 1 AND 
    auditor_report.true_water_source_score != water_quality.subjective_quality_score
    ) AS incorrect_records
GROUP BY employee_name
ORDER BY number_of_mistakes DESC
)
SELECT AVG(number_of_mistakes)
FROM error_count; -- this query checks for the average number of errors made

WITH error_count AS (
SELECT
 employee_name, 
 COUNT(employee_name) AS number_of_mistakes
 FROM(
	SELECT 
    auditor_report.location_id AS location_id,
    visits.record_id,
    employee.employee_name,
    auditor_report.true_water_source_score AS auditor_score,
    water_quality.subjective_quality_score AS surveyor_score
FROM
    auditor_report
JOIN
	visits
ON
	auditor_report.location_id = visits.location_id
JOIN
	water_quality
ON
	visits.record_id=water_quality.record_id
JOIN
	employee
ON
	visits.assigned_employee_id=employee.assigned_employee_id
WHERE
	visits.visit_count = 1 AND 
    auditor_report.true_water_source_score != water_quality.subjective_quality_score
    ) AS incorrect_records
GROUP BY employee_name
ORDER BY number_of_mistakes DESC
)
SELECT 
	employee_name,
    number_of_mistakes
FROM
	error_count
WHERE number_of_mistakes > (SELECT AVG(number_of_mistakes) AS avg_error_count_per_empl
FROM error_count); -- this query checks the employees that have errors greater than the average number of errors


-- cleaning up our previous queries


-- converting incorrect_records to a VIEW
CREATE VIEW Incorrect_records AS (
	SELECT 
    auditor_report.location_id AS location_id,
    visits.record_id,
    employee.employee_name,
    auditor_report.true_water_source_score AS auditor_score,
    water_quality.subjective_quality_score AS surveyor_score,
    auditor_report.statements AS statements
FROM
    auditor_report
JOIN
	visits
ON
	auditor_report.location_id = visits.location_id
JOIN
	water_quality
ON
	visits.record_id=water_quality.record_id
JOIN
	employee
ON
	visits.assigned_employee_id=employee.assigned_employee_id
WHERE
	visits.visit_count = 1 AND 
    auditor_report.true_water_source_score != water_quality.subjective_quality_score
    );
    
WITH error_count AS ( -- This CTE calculates the number of mistakes each employee made
SELECT
employee_name,
COUNT(employee_name) AS number_of_mistakes
FROM
Incorrect_records
/* Incorrect_records is a view that joins the audit report to the database
for records where the auditor and
employees scores are different*/
GROUP BY
	employee_name)
-- Query
SELECT * FROM error_count;

WITH error_count AS ( -- This CTE calculates the number of mistakes each employee made
SELECT
employee_name,
COUNT(employee_name) AS number_of_mistakes
FROM
Incorrect_records
/* Incorrect_records is a view that joins the audit report to the database
for records where the auditor and
employees scores are different*/
GROUP BY
	employee_name)
-- Query
SELECT AVG(number_of_mistakes) AS average_error FROM error_count; -- checks for the average errors made


WITH error_count AS ( -- This CTE calculates the number of mistakes each employee made
SELECT
employee_name,
COUNT(employee_name) AS number_of_mistakes
FROM
Incorrect_records
/* Incorrect_records is a view that joins the audit report to the database
for records where the auditor and
employees scores are different*/
GROUP BY
	employee_name)
-- Query
SELECT 
	employee_name,
    number_of_mistakes 
FROM
	error_count
WHERE
	number_of_mistakes > ( SELECT AVG(number_of_mistakes) FROM error_count); -- checking the employees with mistakes greater than the average number of mistakes
    
	-- making error_count a VIEW
CREATE VIEW error_count AS (
SELECT
employee_name,
COUNT(employee_name) AS number_of_mistakes
FROM
Incorrect_records
/* Incorrect_records is a view that joins the audit report to the database
for records where the auditor and
employees scores are different*/
GROUP BY
	employee_name);
    

WITH suspect_list AS(
SELECT
employee_name,
number_of_mistakes
FROM error_count
WHERE number_of_mistakes > (SELECT AVG(number_of_mistakes) as avg_error_count_per_empl FROM error_count)
) 
SELECT * 
FROM suspect_list;

-- Now we can filter that Incorrect_records view to identify all of the records associated with the four employees we identified.
WITH suspect_list AS(
SELECT
employee_name,
number_of_mistakes
FROM error_count
WHERE number_of_mistakes > (SELECT AVG(number_of_mistakes) as avg_error_count_per_empl FROM error_count)
)
SELECT employee_name, location_id, statements
FROM incorrect_records
WHERE employee_name IN (SELECT employee_name FROM suspect_list);


-- Filter the records that refer to "cash"
WITH suspect_list AS(
SELECT
employee_name,
number_of_mistakes
FROM error_count
WHERE number_of_mistakes > (SELECT AVG(number_of_mistakes) as avg_error_count_per_empl FROM error_count)
)
SELECT employee_name, location_id, statements
FROM incorrect_records
WHERE employee_name IN (SELECT employee_name FROM suspect_list)
AND statements LIKE "%cash%";

-- To Check if there are any employees in the Incorrect_records table with statements mentioning "cash" that are not in our suspect list.

WITH suspect_list AS(
SELECT
employee_name,
number_of_mistakes
FROM error_count
WHERE number_of_mistakes > (SELECT AVG(number_of_mistakes) as avg_error_count_per_empl FROM error_count)
)
SELECT employee_name, location_id, statements
FROM incorrect_records
WHERE employee_name NOT IN (SELECT employee_name FROM suspect_list)
AND statements LIKE "%cash%";

/* After running the above query, I got an empty result,
so this means no one, except the four suspects, has these allegations of bribery. */

/* So we can sum up the evidence we have for the four employees, that:
1. They all made more mistakes than their peers on average.
2. They all have incriminating statements made against them, and only them.
Keep in mind, that this is not decisive proof, but it is concerning enough that we should flag it */