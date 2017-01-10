CREATE TABLE [dbo].[IQ_ReportType](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[Identity] [varchar](100) NULL,
	[MasterReportType] [varchar](50) NOT NULL,
	[Description] [varchar](255) NULL,
	[Settings] [xml] NULL,
	[DateCreated] [datetime] NULL,
	[IsActive] [bit] NOT NULL,
	[IsDefault] [bit] NULL,
 CONSTRAINT [PK_IQ_ReportType] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[IQ_ReportType] ADD  CONSTRAINT [DF_IQ_ReportType_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO