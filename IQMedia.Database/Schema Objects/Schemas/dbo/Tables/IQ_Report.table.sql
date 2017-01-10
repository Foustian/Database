CREATE TABLE [dbo].[IQ_Report](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ReportGUID] [uniqueidentifier] NULL,
	[Title] [varchar](500) NULL,
	[_ReportTypeID] [int] NOT NULL,
	[_ReportImageID] [bigint] NULL,
	[ReportRule] [xml] NULL,
	[ClientGuid] [uniqueidentifier] NOT NULL,
	[ReportDate] [datetime] NULL,
	[DateCreated] [datetime] NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]

GO