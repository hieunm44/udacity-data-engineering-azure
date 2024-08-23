# Project Overview
## Project Introduction
The City of New York would like to develop a Data Analytics platform on Azure Synapse Analytics to accomplish two primary objectives:
1. Analyze how the City's financial resources are allocated and how much of the City's budget is being devoted to overtime.
2. Make the data available to the interested public to show how the City’s budget is being spent on salary and overtime pay for all municipal employees.
You have been hired as a Data Engineer to create high-quality data pipelines that are dynamic, can be automated, and monitored for efficient operation. The project team also includes the city’s quality assurance experts who will test the pipelines to find any errors and improve overall data quality.

The source data resides in Azure Data Lake and needs to be processed in a NYC data warehouse. The source datasets consist of CSV files with Employee master data and monthly payroll data entered by various City agencies.
![](https://video.udacity-data.com/topher/2024/January/65b989ea_nyc-payroll-db-schema/nyc-payroll-db-schema.jpeg)
In the following pages, we will go through the project instructions and by the end you will have built a Data Integration Pipelines on the NYC Payroll Data. We will be using Azure Data Factory to create Data views in Azure SQL DB from the source data files in DataLake Gen2. Then we built our dataflows and pipelines to create payroll aggregated data that will be exported to a target directory in DataLake Gen2 storage over which Synapse Analytics external table is built. At a high level your pipeline will look like below

![](https://video.udacity-data.com/topher/2024/January/65b98a0f_data-integration-pipelines-overview/data-integration-pipelines-overview.jpeg)


# Instructions: Create and Configure Resources
## Project Instructions
For this project, you'll do your work in the Azure Portal, using several Azure resources including:
* Azure Data Lake Gen2
* Azure SQL DB
* Azure Data Factory
* Azure Synapse Analytics
Instructions for using a temporary Azure account to complete the project are on the previous page.
### Project Data
[Download these .csv files](https://video.udacity-data.com/topher/2022/May/6283aff5_data-nyc-payroll/data-nyc-payroll.zip) that provide the data for the project.

## Step 1: Prepare the Data Infrastructure
Setup Data and Resources in Azure
### 1.Create the data lake and upload data
Log into your temporary Azure account (instructions on the previous page) and create the following resources. Please use the provided resource group to create each resource. You will use these resources for the whole project, in all of the steps, so you'll only need to create one of each:

Create an Azure Data Lake Storage Gen2 (storage account) and associated storage container resource named `adlsnycpayroll-yourfirstname-lastintial`.

In the Azure Data Lake Gen2 creation flow, go to Advanced tab and ensure below options are checked:
* Require secure transfer for REST API operations
* Allow enabling anonymous access on individual containers
* Enable storage account key access
* Default to Microsoft Entra authorization in the Azure portal
* Enable hierarchical namespace

Create three directories in this storage container named
* dirpayrollfiles
* dirhistoryfiles
* dirstaging

`dirstaging` will be used by the pipelines we will create as part of the project to store staging data for integration with Azure Synapse. This will be discussed in further pages

Upload these files from the [project data](https://video.udacity-data.com/topher/2022/May/6283aff5_data-nyc-payroll/data-nyc-payroll.zip) to the `dirpayrollfiles` folder
* EmpMaster.csv
* AgencyMaster.csv
* TitleMaster.csv
* nycpayroll_2021.csv
Upload this file (historical data) from the [project data](https://video.udacity-data.com/topher/2022/May/6283aff5_data-nyc-payroll/data-nyc-payroll.zip) to the `dirhistoryfiles` folder
* nycpayroll_2020.csv
### 2. Create an Azure Data Factory Resource
### 3. Create a SQL Database
In the Azure portal, create a SQL Database resource named `db_nycpayroll`.

In the creation steps, you will be required to create a SQL server, create a server with Service tier: Basic (For less demanding workloads).
![](https://video.udacity-data.com/topher/2024/January/65b98b7f_screenshot-2024-01-18-155931/screenshot-2024-01-18-155931.jpeg)
In Networking tab, allow both of the below options:
* Allow Azure services and resources to access this server
* Add current client IP address
### 4. Create a Synapse Analytics workspace, or use one you already have created.
Under Synapse, you will not be allowed to run SQL commands in the default main database. Use the below command to create a database and then refresh the database selector dropdown and choose your created database before running any queries.
```sql
CREATE DATABASE udacity
```
* You are only allowed one Synapse Analytics workspace per Azure account, a Microsoft restriction.
* Create a new Azure Data Lake Gen2 and file system for Synapse Analytics when you are creating the Synapse Analytics workspace in the Azure portal.

As part of the recent updates to the Udacity cloud labs, you will not be allowed to create SQL dedicated pool in the Synapse Analytics workspace. As a result, you cannot use  `CREATE TABLE` SQL scripts. We recommend you use the default built-in serverless SQL pool, and use `CREATE EXTERNAL TABLE` and `CREATE EXTERNAL` TABLE AS SELECT (CETAS) instead. [CETAS](https://learn.microsoft.com/en-us/azure/synapse-analytics/sql/develop-tables-cetas#cetas-in-serverless-sql-pool) creates external tables and exports the SELECT query results to a set of files in your storage account.
### 5. Create summary data external table in Synapse Analytics workspace
* Define the file format, if not already, for reading/saving the data from/to a comma delimited file in blob storage.
```sql
-- Use the same file format as used for creating the External Tables during the LOAD step.
IF NOT EXISTS (SELECT * FROM sys.external_file_formats WHERE name = 'SynapseDelimitedTextFormat') 
CREATE EXTERNAL FILE FORMAT [SynapseDelimitedTextFormat] 
WITH ( FORMAT_TYPE = DELIMITEDTEXT ,
FORMAT_OPTIONS (
FIELD_TERMINATOR = ',',
USE_TYPE_DEFAULT = FALSE
))
GO
```
* Define the data source to persist the results.Use the blob storage account name as applicable to you.
* Create external table that references the dirstaging directory of DataLake Gen2 storage for staging payroll summary data. (Pipeline for this will be created in later section)
```sql
CREATE EXTERNAL TABLE [dbo].[NYC_Payroll_Summary](
[FiscalYear] [int] NULL,
[AgencyName] [varchar](50) NULL,
[TotalPaid] [float] NULL
)
WITH (
LOCATION = '/',
DATA_SOURCE = [mydlsfs20230413_mydls20230413_dfs_core_windows_net],
FILE_FORMAT = [SynapseDelimitedTextFormat]
)
GO
```
In the code snippet above, the data will be stored in the ‘/’ directory in the blob storage in dirstaging (this was configured when creating datasource). You can change the location as you desire. Also, change the DATA_SOURCE value, as applicable to you. Note that, `mydls20230413` is the Data Lake Gen 2 storage name, and `mydlsfs20230413` is the name of the file system (container).
### 6. Create master data tables and payroll transaction tables in SQL DB
* Create Employee Master Data table:
```sql
CREATE TABLE [dbo].[NYC_Payroll_EMP_MD](
[EmployeeID] [varchar](10) NULL,
[LastName] [varchar](20) NULL,
[FirstName] [varchar](20) NULL
) 
GO
```
* Create Job Title Table:
```sql
CREATE TABLE [dbo].[NYC_Payroll_TITLE_MD](
[TitleCode] [varchar](10) NULL,
[TitleDescription] [varchar](100) NULL
)
GO
```
* Create Agency Master table:
```sql
CREATE TABLE [dbo].[NYC_Payroll_AGENCY_MD](
    [AgencyID] [varchar](10) NULL,
    [AgencyName] [varchar](50) NULL
) 
GO
```
* Create Payroll 2020 transaction data table:
```sql
CREATE TABLE [dbo].[NYC_Payroll_Data_2020](
    [FiscalYear] [int] NULL,
    [PayrollNumber] [int] NULL,
    [AgencyID] [varchar](10) NULL,
    [AgencyName] [varchar](50) NULL,
    [EmployeeID] [varchar](10) NULL,
    [LastName] [varchar](20) NULL,
    [FirstName] [varchar](20) NULL,
    [AgencyStartDate] [date] NULL,
    [WorkLocationBorough] [varchar](50) NULL,
    [TitleCode] [varchar](10) NULL,
    [TitleDescription] [varchar](100) NULL,
    [LeaveStatusasofJune30] [varchar](50) NULL,
    [BaseSalary] [float] NULL,
    [PayBasis] [varchar](50) NULL,
    [RegularHours] [float] NULL,
    [RegularGrossPaid] [float] NULL,
    [OTHours] [float] NULL,
    [TotalOTPaid] [float] NULL,
    [TotalOtherPay] [float] NULL
) 
GO
```
* Create Payroll 2021 transaction data table:
```sql
CREATE TABLE [dbo].[NYC_Payroll_Data_2021](
    [FiscalYear] [int] NULL,
    [PayrollNumber] [int] NULL,
    [AgencyCode] [varchar](10) NULL,
    [AgencyName] [varchar](50) NULL,
    [EmployeeID] [varchar](10) NULL,
    [LastName] [varchar](20) NULL,
    [FirstName] [varchar](20) NULL,
    [AgencyStartDate] [date] NULL,
    [WorkLocationBorough] [varchar](50) NULL,
    [TitleCode] [varchar](10) NULL,
    [TitleDescription] [varchar](100) NULL,
    [LeaveStatusasofJune30] [varchar](50) NULL,
    [BaseSalary] [float] NULL,
    [PayBasis] [varchar](50) NULL,
    [RegularHours] [float] NULL,
    [RegularGrossPaid] [float] NULL,
    [OTHours] [float] NULL,
    [TotalOTPaid] [float] NULL,
    [TotalOtherPay] [float] NULL
) 
GO
```
* Create Payroll summary data table:
```sql
CREATE TABLE [dbo].[NYC_Payroll_Summary](
    [FiscalYear] [int] NULL,
    [AgencyName] [varchar](50) NULL,
    [TotalPaid] [float] NULL 
)
GO
```
Capture screenshot of the below
* DataLakeGen2 that shows files are uploaded
* Above 5 tables created in SQL db
* External table created in Synapse


# Instructions: Create Linked Services
## Step 2: Create Linked Services
### 1.Create a Linked Service for Azure Data Lake
In Azure Data Factory, create a linked service to the data lake that contains the data files
* From the data stores, select Azure Data Lake Gen 2
* Test the connection
### 2.Create a Linked Service to SQL Database that has the current (2021) data
* If you get a connection error, remember to add the IP address to the firewall settings in SQL DB in the Azure Portal
* Set the Version to Legacy to avoid MissingRequiredPropertyException error in the Data Flows creation step
![](https://video.udacity-data.com/topher/2024/June/66681439_2/2.jpeg)
* Capture screenshot of Linked Services page after successful creation
* Save configs of Linked Services after creation


# Instructions: Create Datasets
## Step 3: Create Datasets in Azure Data Factory
###1.Create the datasets for the 2021 Payroll file on Azure Data Lake Gen2
* Select DelimitedText
* Set the path to the nycpayroll_2021.csv in the Data Lake
* Preview the data to make sure it is correctly parsed
### 2. Repeat the same process to create datasets for the rest of the data files in the Data Lake
* EmpMaster.csv
* TitleMaster.csv
* AgencyMaster.csv
* Remember to publish all the datasets
### 3. Create the dataset for all the data tables in SQL DB
### 4. Create the datasets for destination (target) table in Synapse Analytics
* dataset for NYC_Payroll_Summary
* Capture screenshots of datasets in Data Factory
* Save configs of datasets from Data Factory


# Instructions: Create Data Flows
## Step 4: Create Data Flows
In Azure Data Factory, create data flow to load 2020 Payroll data from Azure DataLake Gen2 storage to SQL db table created earlier
1. Create a new data flow
2. Select the dataset for 2020 payroll file as the source
3. Click on the + icon at the bottom right of the source, from the options choose sink. A sink will get added in the dataflow
4. Select the sink dataset as 2020 payroll table created in SQL db
Repeat the same process to add data flow to load data for each file in Azure DataLake to the corresponding SQL DB tables.
* Capture screenshots of dataflows in Data Factory
* Save configs of dataflows from Data Factory


# Instructions: Aggregate Data Flow
## Step 5: Data Aggregation and Parameterization
In this step, you'll extract the 2021 year data and historical data, merge, aggregate and store it in DataLake staging area which will be used by Synapse Analytics external table. The aggregation will be on Agency Name, Fiscal Year and TotalPaid.
1. Create new data flow and name it Dataflow Summary
2. Add source as payroll 2020 data from SQL DB
3. Add another source as payroll 2021 data from SQL DB
4. Create a new Union activity and select both payroll datasets as the source
5. Make sure to do any source to target mappings if required. This can be done by adding a Select activity before Union
6. After Union, add a Filter activity, go to Expression builder
    a. Create a parameter named- dataflow_param_fiscalyear and give value 2020 or 2021
    b. Include expression to be used for filtering: toInteger(FiscalYear) >= $dataflow_param_fiscalyear
7. Now, choose Derived Column after filter
    a. Name the column: TotalPaid
    b. Add following expression: RegularGrossPaid + TotalOTPaid+TotalOtherPay
8. Add an Aggregate activity to the data flow next to the TotalPaid activity
    a. Under Group by, select AgencyName and FiscalYear
    b. Set the expression to sum(TotalPaid)
9. Add a Sink activity after the Aggregate
    a. Select the sink as summary table created in SQL db
    b. In Settings, tick Truncate table
10. Add another Sink activity, this will create two sinks after Aggregate
    a. Select the sink as dirstaging in Azure DataLake Gen2 storage
    b. In Settings, tick Clear the folder

* Capture screenshot of aggregate dataflow in Data Factory
* Save config of aggregate dataflow from Data Factory


# Instructions: Create and Run Pipeline
## Step 6: Pipeline Creation
Now, that you have the data flows created it is time to bring the pieces together and orchestrate the flow.

We will create a pipeline to load data from Azure DataLake Gen2 storage in SQL db for individual datasets, perform aggregations and store the summary results back into SQL db destination table and datalake staging storage directory which will be consumed by Synapse Analytics via CETAS.
1. Create a new pipeline
2. Include dataflows for Agency, Employee and Title to be parallel
3. Add dataflows for payroll 2020 and payroll 2021. These should run only after the initial 3 dataflows have completed
4. After payroll 2020 and payroll 2021 dataflows have completed, dataflow for aggregation should be started.
5. Refer to the below screenshot. Your final pipeline should look like this
![](https://video.udacity-data.com/topher/2024/January/65b990c5_screenshot-2024-01-31-054225/screenshot-2024-01-31-054225.jpeg)

## Step 7: Trigger and Monitor Pipeline
1. Select Add trigger option from pipeline view in the toolbar
2. Choose trigger now to initiate pipeline run
3. You can go to monitor tab and check the Pipeline Runs
4. Each dataflow will have an entry in Activity runs list

## Step 8: Verify Pipeline run artifacts
1. Query data in SQL DB summary table (destination table). This is one of the sinks defined in the pipeline.
2. Check the dirstaging directory in Datalake if files got created. This is one of the sinks defined in the pipeline
3. Query data in Synapse external table that points to the dirstaging directory in Datalake.

* Capture screenshot of pipeline resource from Datafactory
* Save config of pipeline from Data Factory
* Capture screenshot of successful pipeline run. All activity runs and dataflow success indicators should be visible
* Capture screenshot of query from SQL DB summary table
* Capture screenshot of dirstaging directory listing in Datalake that shows files saved after pipeline runs
* Capture screenshot of query from Synapse summary external table


# Instructions: Connect Project to Github and Submit
## Step 9: Connect your Project to Github
In this step, you'll connect Azure Data Factory to Github
* Login to your Github account and create a new Repo in Github
* Connect Azure Data Factory to Github
* Select your Github repository in Azure Data Factory
* Publish all objects to the repository in Azure Data Factory
