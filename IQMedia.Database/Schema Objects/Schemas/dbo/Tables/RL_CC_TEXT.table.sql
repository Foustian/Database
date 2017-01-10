CREATE TABLE [dbo].[RL_CC_TEXT](
	[RL_CC_TEXTKey] [bigint] IDENTITY(1,1) NOT NULL,
	[RL_Station_ID] [varchar](50) NULL,
	[RL_Station_Date] [date] NULL,
	[RL_Station_Time] [int] NULL,
	[RL_Time_Zone] [varchar](150) NULL,
	[RL_CC_FileName] [varchar](150) NULL,
	[RL_CC_File_Location] [varchar](250) NULL,
	[GMT_Date] [date] NULL,
	[GMT_Time] [int] NULL,
	[IQ_CC_Key] [varchar](150) NULL,
	[CC_File_Status] [varchar](50) NULL,
	[CC_Ingest_Date] [datetime] NULL,
	[CreatedBy] [varchar](50) NULL,
	[ModifiedBy] [varchar](50) NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedDate] [datetime] NULL,
	[IsActive] [bit] NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_RL_CC_TEXT] PRIMARY KEY CLUSTERED 
(
	[RL_CC_TEXTKey] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY],
 CONSTRAINT [IX_RL_CC_TEXT] UNIQUE NONCLUSTERED 
(
	[RL_CC_TEXTKey] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]