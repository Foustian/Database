CREATE TABLE [dbo].[IQ_Nielsen_Averages](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Affil_IQ_CC_Key] [varchar](28) NULL,
	[Avg_Ratings_Pt] [float] NULL,
	[IQ_Start_Point] [float] NULL,
	[DAYPARTID] [int] NULL,
 CONSTRAINT [PK_IQ_Nielsen_Averages] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]