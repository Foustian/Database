CREATE TABLE [dbo].[IQCore_Recording](
	[ID] [int] IDENTITY(8000000,1) NOT NULL,
	[_SourceGuid] [uniqueidentifier] NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NOT NULL
) ON [PRIMARY]