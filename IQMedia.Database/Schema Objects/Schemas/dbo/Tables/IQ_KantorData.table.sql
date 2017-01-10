CREATE TABLE [dbo].[IQ_KantorData](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[IQ_CC_Key] [varchar](50) NULL,
	[Station_ID] [varchar](50) NULL,
	[GMT_air_datetime] [datetime] NULL,
	[audience] [xml] NULL,
	[CreatedDate] [datetime] NULL,
	[IsActive] [bit] NULL,
 CONSTRAINT [PK_IQ_KantorData] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

