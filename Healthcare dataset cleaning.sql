SELECT *
FROM [social_media].[dbo].[dirty_healthcare-data]

--duplicate the dataset before cleaning
SELECT *
INTO dirty_healthcare_data
FROM [social_media].[dbo].[dirty_healthcare-data]

SELECT *
FROM dirty_healthcare_data

---drop duplicates----

WITH CTE AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY ID, Name, Age, Gender, Salary ORDER BY (SELECT NULL)) AS row_num
    FROM dirty_healthcare_data
)
DELETE 
FROM CTE
WHERE row_num > 1;



------checking the ID column for duplicates, ensuring they are all unique numbers---
SELECT ID, COUNT(*) AS count
FROM dirty_healthcare_data
GROUP BY ID
HAVING COUNT(*) > 1;
--there are IDs that occured more than once


-----New Unique ID values----
WITH CTE2 AS (
    SELECT 
        ID,
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) + 1000 AS new_ID
    FROM dirty_healthcare_data
)
UPDATE dirty_healthcare_data
SET ID = CTE2.new_ID
FROM dirty_healthcare_data
JOIN CTE2 ON dirty_healthcare_data.ID = CTE2.ID;


--------cleaning the Name column, the first and last name first letter should be upper case while the other letters will be lower case-------

--checking for null values
SELECT Name--, COUNT(*) AS count
FROM dirty_healthcare_data
WHERE Name IS NULL
--no null values

WITH cleaned AS (
    SELECT 
        d.Name AS original_name,
        STRING_AGG(
            UPPER(LEFT(value, 1)) + LOWER(SUBSTRING(value, 2, LEN(value))),
            ' '
        ) AS cleaned_name
    FROM dirty_healthcare_data d
    CROSS APPLY STRING_SPLIT(d.Name, ' ')
    GROUP BY d.Name
)
UPDATE d
SET d.Name = c.cleaned_name
FROM dirty_healthcare_data d
JOIN cleaned c
ON d.Name = c.original_name;

-----------------cleaning  the age column----------

--checking the number of null values----
SELECT COUNT(*)
FROM dirty_healthcare_data
WHERE Age IS NULL
----There are 60 null values in the age columns

---filling up the null values by the average age o education---

WITH AvgAgeByEducation AS (
    SELECT 
        Education,
        AVG(Age) AS avg_age
    FROM dirty_healthcare_data
    WHERE Age IS NOT NULL
    GROUP BY Education
)
UPDATE dirty_healthcare_data
SET Age = (
    SELECT avg_age
    FROM AvgAgeByEducation
    WHERE dirty_healthcare_data.Education = AvgAgeByEducation.Education
)
WHERE Age IS NULL;


UPDATE dirty_healthcare_data
SET Age = (
    SELECT avg_age
    FROM AvgAgeByEducation
    WHERE dirty_healthcare_data.Education = AvgAgeByEducation.Education
)
WHERE Age IS NULL;

---The averages are really low, which means that there are outliners i.e there are ages that are small which is unrealistic---
---this shows that the collection of data is faulty---
---the age column might not be useful in building a machine learning model---


-----------------checking the number of Null Values in the gender column----------------
SELECT COUNT(*)
FROM dirty_healthcare_data
WHERE Gender IS NULL
--There are 1626 null values--
--this column is not useful and cant be used fro analysis---


-----checking for null values in the blood type column--- 
SELECT COUNT(*)
FROM dirty_healthcare_data
WHERE Blood_Type IS NULL
--there are 8 null values


----cleaning the salary column to mak it an int column----

--removing the dollar sign
UPDATE dirty_healthcare_data
SET Salary = REPLACE(Salary, '$', ' ')

---removing the space
UPDATE dirty_healthcare_data
SET Salary = REPLACE(Salary, ' ', '')

--replacing the opening bracket '(' for '-' only for the salary that are negative---
UPDATE dirty_healthcare_data
SET Salary = CASE 
    WHEN LEFT(Salary, 1) = '(' THEN 
        '-' + SUBSTRING(Salary, 2, LEN(Salary))
    ELSE Salary
END;

--creating a new column for only Salary status---

ALTER TABLE dirty_healthcare_data
ADD Salary_Status nvarchar(50);


UPDATE dirty_healthcare_data
 SET Salary_Status =  CASE 
        WHEN PATINDEX('%[A-Za-z]%', Salary) > 0 THEN 
            SUBSTRING(Salary, PATINDEX('%[A-Za-z]%', Salary), LEN(Salary))
        ELSE 'NULL'
END;


--removing the texts from the salary column--- 
UPDATE dirty_healthcare_data
SET Salary = LEFT(Salary, PATINDEX('%[A-Za-z]%', Salary) - 1)
WHERE PATINDEX('%[A-Za-z]%', Salary) > 0;

-----cleaning the salary column, removing '(', ')'-----
UPDATE dirty_healthcare_data
SET Salary = REPLACE(Salary, '(', '')

UPDATE dirty_healthcare_data
SET Salary = REPLACE(Salary, ')', ' ')



--renaming the Salary column name from salary to salary($), to indicate that the  salaries are in dollars----
EXEC sp_rename
'dirty_healthcare_data.Salary',
'Salary($)', 'COLUMN';

--removing ')' from salary_status----
UPDATE dirty_healthcare_data
SET Salary_Status = REPLACE(Salary_Status, ')', '')


----ANALYSIS----

-------------cities or demographics with higher healthcare needs based on health conditions and admission dates.---------

--looking at cities with the highest poor health condition--

SELECT City, COUNT(Health_Condition) as poor_state
FROM dirty_healthcare_data
WHERE Health_Condition = 'Poor'
GROUP BY City
ORDER BY poor_state
---the city of Atlanta has a high number of patient with poor health conditions---


SELECT City, Count(City) as cities_with_higher_health_needs
FROM (SELECT TOP (30) City, Date_of_Admission, Health_Condition
FROM dirty_healthcare_data
WHERE Health_Condition = 'Poor'
ORDER BY Date_of_Admission DESC
) as sub
GROUP BY City
--according date of admision, the city of Atlanta has recorded patients with poor health conditions--