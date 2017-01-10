CREATE TABLE [dbo].[IQLog_Ingestion] (
    [ID] [bigint] IDENTITY(1,1) NOT NULL,
	[StationID] [varchar](20) NOT NULL,
	[IQ_CC_Key] [varchar](20) NULL,
	[MediaType] [varchar](10) NOT NULL,
	[Date] [datetime2](7) NOT NULL,
	[Level] [varchar](20) NOT NULL,
	[Logger] [varchar](250) NOT NULL,
	[LogMessage] [varchar](4000) NOT NULL
);

