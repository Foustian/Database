CREATE TABLE [dbo].[IQService_ReportPDFExport](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[CustomerGuid] [uniqueidentifier] NOT NULL,
	[BaseUrl] [varchar](100) NOT NULL,
	[Status] [varchar](50) NOT NULL,
	[_RootPathID] [int] NULL,
	[DownloadPath] [varchar](255) NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[MachineName] [varchar](255) NULL,
	[HTMLFilename] [varchar](255) NULL,
	[_ReportGUID] [uniqueidentifier] NULL,
 CONSTRAINT [PK_IQService_ReportPDFExport] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO