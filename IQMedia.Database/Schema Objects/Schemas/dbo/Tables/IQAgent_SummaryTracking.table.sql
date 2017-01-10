CREATE TABLE [dbo].[IQAgent_SummaryTracking](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Operation] [varchar](50) NULL,
	[SP] [varchar](255) NULL,
	[OperationTable]	[varchar](150) NULL,
	[RecordsBeforeUpdation] [bigint] NULL,
	[RecordsAfterUpdation] [bigint] NULL,
	[Detail] [varchar](max) NULL,
	[DateTime] [datetime] NULL,
 CONSTRAINT [PK_IQAgent_SummaryTracking] PRIMARY KEY CLUSTERED ( [ID] ASC )
) ON [PRIMARY]