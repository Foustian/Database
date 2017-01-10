CREATE TABLE [dbo].[IQ_Five_Min_Staging](
	[IQ_FiveMS_Key] [bigint] IDENTITY(1,1) NOT NULL,
	[IQ_CC_Key] [varchar](150) NULL,
	[Media_Recordfile_GUID] [uniqueidentifier] NULL,
	[Last_Media_Segment] [int] NULL,
	[Current_Active_Media_File] [varchar](150) NULL,
	[Media_Process_Status] [varchar](50) NULL,
	[CCTxt_Recordfile_GUID] [uniqueidentifier] NULL,
	[Last_CCTxt_Segment] [int] NULL,
	[Current_Active_CCTxt_File] [varchar](150) NULL,
	[CC_Process_Status] [varchar](50) NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedDate] [datetime] NULL
) ON [PRIMARY]