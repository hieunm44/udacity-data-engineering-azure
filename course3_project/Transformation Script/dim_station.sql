IF NOT EXISTS (SELECT * FROM sys.external_file_formats WHERE name = 'SynapseDelimitedTextFormat') 
	CREATE EXTERNAL FILE FORMAT [SynapseDelimitedTextFormat] 
	WITH ( FORMAT_TYPE = DELIMITEDTEXT ,
	       FORMAT_OPTIONS (
			 FIELD_TERMINATOR = ',',
			 USE_TYPE_DEFAULT = FALSE
			))
GO

IF NOT EXISTS (SELECT * FROM sys.external_data_sources WHERE name = 'udacitydata_hieudatalake97_dfs_core_windows_net') 
	CREATE EXTERNAL DATA SOURCE [udacitydata_hieudatalake97_dfs_core_windows_net] 
	WITH (
		LOCATION = 'abfss://udacitydata@hieudatalake97.dfs.core.windows.net' 
	)
GO

IF OBJECT_ID('dbo.dim_station') IS NOT NULL 
BEGIN 
  DROP EXTERNAL TABLE [dbo].[dim_station]; 
END

CREATE EXTERNAL TABLE dbo.dim_station
WITH (
    LOCATION     = 'dim_station',
    DATA_SOURCE = [udacitydata_hieudatalake97_dfs_core_windows_net],
    FILE_FORMAT = [SynapseDelimitedTextFormat]
)  
AS
SELECT [station_id],
	[name],
	[latitude],
	[longitude]
FROM [dbo].[staging_station];

SELECT TOP 100 * FROM dbo.dim_station
GO
