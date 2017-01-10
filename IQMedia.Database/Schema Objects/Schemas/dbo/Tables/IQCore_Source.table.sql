CREATE TABLE [dbo].[IQCore_Source] (
    [Guid] [uniqueidentifier] NOT NULL,
	[SourceID] [varchar](20) NOT NULL,
	[Title] [varchar](255) NOT NULL,
	[Logo] [varchar](150) NOT NULL,
	[URL] [varchar](255) NULL,
	[BroadcastType] [varchar](50) NOT NULL,
	[BroadcastLocation] [varchar](255) NOT NULL,
	[RetentionDays] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[_TimezoneID] [int] NOT NULL
);

