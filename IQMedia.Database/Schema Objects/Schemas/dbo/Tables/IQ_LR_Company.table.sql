CREATE TABLE [dbo].[IQ_LR_Company](
	[ID] [bigint] NOT NULL,
	[Company_Name] [varchar](100) NOT NULL,
	[Ranks] [smallint] NULL,
	[Industry] [varchar](100) NULL,
	[Location] [varchar](100) NULL,
	[Brand] [varchar](100) NULL,
	[Forbes100_Brands] [smallint] NULL,
	[IsActive] [bit] NOT NULL CONSTRAINT [DF_IQ_LR_Company_IsActive]  DEFAULT ((1)),
 CONSTRAINT [PK_IQ_LR_Company] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
