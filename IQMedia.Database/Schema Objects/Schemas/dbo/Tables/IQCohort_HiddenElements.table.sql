USE [IQMediaGroup]
GO

/****** Object:  Table [dbo].[IQCohort_HiddenElements]    Script Date: 12/8/2016 11:43:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[IQCohort_HiddenElements](
	[Report] [varchar](50) NOT NULL,
	[HiddenElements] [varchar](500) NOT NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

