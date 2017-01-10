CREATE TABLE [dbo].[IQ_DayPart](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[DP_Affil_Code] [varchar](2) NULL,
	[DOW] [smallint] NULL,
	[TOD] [int] NULL,
	[Kantar_DayPart_Name] [varchar](50) NULL,
	[Kantar_DayPart_Code] [varchar](10) NULL,
	[IQ_DayPart_Name] [varchar](50) NULL,
	[IQ_DayPart_Code] [varchar](10) NULL,
	[CreatedDate] [datetime] NULL CONSTRAINT [DF_IQ_DayPart_CreatedDate]  DEFAULT (getdate()),
	[ModifiedDate] [datetime] NULL CONSTRAINT [DF_IQ_DayPart_ModifiedDate]  DEFAULT (getdate()),
	[IsActive] [bit] NULL CONSTRAINT [DF_IQ_DayPart_IsActive]  DEFAULT ((1)),
 CONSTRAINT [PK_IQ_DayPart] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]