USE [IQMediaGroup]
GO

/****** Object:  Table [dbo].[IQCore_Timezone]    Script Date: 11/1/2016 4:24:15 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[IQCore_Timezone](
	[ID] [int] NOT NULL,
	[Code] [char](4) NOT NULL,
	[Name] [varchar](45) NOT NULL,
	[gmt_adj] [int] NULL,
	[dst_adj] [int] NULL,
 CONSTRAINT [PK_IQCore_TimeZone] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


