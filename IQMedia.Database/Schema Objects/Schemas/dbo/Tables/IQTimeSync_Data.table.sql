CREATE TABLE [dbo].[IQTimeSync_Data](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[IQ_CC_Key] [varchar](50) NOT NULL,
	[_TypeID] [int] NOT NULL,
	[StationID] [varchar](50) NOT NULL,
	[GMT_Air_DateTime] [datetime] NOT NULL,
	[Data] [varchar](max) NULL,
	[DateModified] [datetime] NOT NULL,
	[IsActive] [datetime] NOT NULL
) ON [PRIMARY]
