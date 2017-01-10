USE [IQMediaGroup]
GO

/****** Object:  Table [dbo].[IQCohort_Cohorts]    Script Date: 12/8/2016 11:41:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[IQCohort_Cohorts](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](250) NOT NULL,
	[CreatedDate] [datetime] NULL CONSTRAINT [DF_Cohort_CreatedDate]  DEFAULT (getdate()),
	[ModifiedDate] [datetime] NULL CONSTRAINT [DF_Cohort_ModifiedDate]  DEFAULT (getdate()),
	[IsActive] [tinyint] NULL CONSTRAINT [DF_Cohort_IsActive]  DEFAULT ((1)),
 CONSTRAINT [PK_Cohort] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

