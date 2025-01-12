 Healthcare Data Cleaning and Analysis
     **Overview**
   
This project focuses on the cleaning and analysis of a healthcare dataset. The data cleaning process aims to remove duplicates, handle missing values, and standardize columns, making the data ready for further analysis. The analysis identifies cities or demographics with higher healthcare needs based on health conditions and admission dates.

   **Data Cleaning Process**
**1. Duplicates Removal**
The dataset contained duplicate rows that were removed to ensure data integrity. The removal process identified rows with duplicate values across multiple columns (ID, Name, Age, Gender, and Salary). Only one instance of each duplicate row was retained.

**2. Ensuring Unique ID**
The ID column, which was supposed to contain unique values, had duplicates. These duplicates were handled by generating new unique IDs starting from 1001 and incrementing by 1. This step ensures that the ID column is unique across all rows.

**3. Name Standardization**
The Name column was cleaned to ensure that the first letter of each name is capitalized, and the rest of the letters are in lowercase. This was achieved by splitting the names and applying the transformation to each word.

**4. Handling Missing Values in Age**
The Age column contained missing values. To address this, the missing ages were filled with the average age of individuals who have the same education status. However, the resulting averages were lower than expected, indicating the presence of outliers in the data. As a result, the Age column may not be reliable for predictive modeling.

**5. Gender Column Analysis**
The Gender column had a significant number of missing values, making it unsuitable for analysis. It was determined that this column would not be used in further analysis.

**6. Cleaning Salary Column**
The Salary column contained non-numeric characters like dollar signs and parentheses. These were removed, and negative salaries were adjusted to reflect proper negative values. Additionally, a new Salary_Status column was created to capture any textual data remaining in the Salary column.

**7. Blood Type Column**
The Blood_Type column had a small number of missing values, which were handled as necessary.

**Data Analysis**
Identifying Cities with Higher Healthcare Needs
Based on the cleaned data, we analyzed the cities that have a higher demand for healthcare services. The following queries were used to identify cities with higher healthcare needs:

Cities with Poor Health Conditions: This query identifies cities with the highest number of patients reporting poor health conditions.

sql

```SELECT City, COUNT(Health_Condition) as poor_state FROM dirty_healthcare_data WHERE Health_Condition = 'Poor' GROUP BY City ORDER BY poor_state```

The city of Atlanta was identified as having the highest number of patients with poor health conditions.


Cities Based on Admission Dates: This query examines the top 30 cities with the most recent admissions for patients reporting poor health conditions.

sql

```SELECT City, Count(City) as cities_with_higher_health_needs FROM (SELECT TOP (30) City, Date_of_Admission, Health_Condition FROM dirty_healthcare_data WHERE Health_Condition = 'Poor' ORDER BY Date_of_Admission DESC) as sub GROUP BY City```

Based on admission dates, Atlanta also had a high number of patients with poor health conditions.

**Limitations of the Data**
**Age Column:** The age column contains outliers, making it difficult to use for analysis or predictive modeling. The average age used to fill missing values may not accurately reflect the true distribution of ages in the dataset.

**Gender Column:** The Gender column had a significant number of missing values, making it unsuitable for further analysis.

**Reliability of Data for Predictive Modeling:** Due to issues with the Age and Gender columns, the data may not be fully reliable for building predictive models. The presence of outliers and missing values may affect the performance of any machine learning model built using this dataset.

**Project Setup**

**1. Prerequisites**
Before running the SQL scripts in this repository, ensure you have the following:

A database management system (DBMS) like SQL Server or Microsoft SQL Server Management Studio (SSMS).
Access to the raw healthcare dataset (dirty_healthcare_data).

**2. Setup Instructions**

Clone this repository:

bash
Copy code
git clone https://github.com/your-username/healthcare-data-cleaning.git
Run the SQL scripts in the order provided:

Start with the data cleaning scripts to process the raw data.
Proceed with the analysis scripts to identify cities with higher healthcare needs.
Ensure that the database schema is consistent with the queries in the scripts. If needed, modify column names or data types to match the structure of your raw data.

**Contributing**
Feel free to fork this repository and submit pull requests. Contributions are welcome for improving the data cleaning process, adding new analysis, or fixing any issues you find.

**License**
This project is licensed under the MIT License - see the LICENSE file for details.

**Acknowledgements**
SQL Server for providing a powerful platform to perform the data cleaning and analysis.
GitHub for providing a platform to share the findings.
