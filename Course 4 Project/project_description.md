# Project Overview
In this project, you'll build a data lake solution for Divvy bikeshare.

Divvy is a bike sharing program in Chicago, Illinois USA that allows riders to purchase a pass at a kiosk or use a mobile application to unlock a bike at stations around the city and use the bike for a specified amount of time. The bikes can be returned to the same station or to another station. The City of Chicago makes the anonymized bike trip data publicly available for projects like this where we can analyze the data.

Since the data from Divvy are anonymous, we have generated fake rider and account profiles along with fake payment data to go along with the data from Divvy. The dataset looks like this:
![](https://video.udacity-data.com/topher/2022/March/6239366d_dend-project-erd/dend-project-erd.jpeg)
The goal of this project is to develop a data lake solution using Azure Databricks using a lake house architecture. You will:
* Design a star schema based on the business outcomes listed below;
* Import the data into Azure Databricks using Delta Lake to create a Bronze data store;
* Create a gold data store in Delta Lake tables;
* Transform the data into the star schema for a Gold data store;

## The business outcomes you are designing for are as follows:
1. Analyze how much time is spent per ride
* Based on date and time factors such as day of week and time of day
* Based on which station is the starting and / or ending station
* Based on age of the rider at time of the ride
* Based on whether the rider is a member or a casual rider
2. Analyze how much money is spent
* Per month, quarter, year
* Per member, based on the age of the rider at account start
3. EXTRA CREDIT - Analyze how much money is spent per member
* Based on how many rides the rider averages per month
* Based on how many minutes the rider spends on a bike per month


# Project Instructions
The goal of this project is to develop a data lake solution using Azure Databricks using a lake house architecture. You will:
* Design a star schema based on the business outcomes below;
* Import the data into Azure Databricks using Delta Lake to create a Bronze data store;
* Create a gold data store in Delta Lake tables;
* Transform the data into the star schema for a Gold data store;

You'll implement these requirements by creating a Python notebook, or notebooks in the Azure Databricks workspace. Detailed requirements for what should be in the notebook can be found in the project rubric. You'll submit your notebook(s) and they'll be assessed against this rubric(opens in a new tab) when you submit your project.

## The business outcomes you are designing for:
1. Analyze how much time is spent per ride
* Based on date and time factors such as day of week and time of day
* Based on which station is the starting and / or ending station
* Based on age of the rider at time of the ride
* Based on whether the rider is a member or a casual rider
2. Analyze how much money is spent
* Per month, quarter, year
* Per member, based on the age of the rider at account start
3. EXTRA CREDIT - Analyze how much money is spent per member
* Based on how many rides the rider averages per month
* Based on how many minutes the rider spends on a bike per month

Design a star schema for these business outcomes. Create a PDF of the schema you'll submit along with your Azure Databricks notebook file(s).