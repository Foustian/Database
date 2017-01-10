USE [IQMediaGroup]
GO

/****** Object:  Table [dbo].[IQ_Analytics_Secondaries]    Script Date: 5/4/2016 16:49:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[IQ_Analytics_Secondaries](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[MainTabs] [varchar](200) NULL,
	[GroupBy] [varchar](50) NOT NULL,
	[ColumnHeaders] [varchar](500) NULL,
	[GroupByHeader] [varchar](50) NULL,
	[GroupByDisplay] [varchar](50) NULL,
	[TabDisplay] [varchar](50) NULL,
	[PageType] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

