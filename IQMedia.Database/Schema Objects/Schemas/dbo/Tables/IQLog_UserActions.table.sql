CREATE TABLE [dbo].[IQLog_UserActions](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[SessionID] [varchar](50) NOT NULL,
	[CustomerID] [bigint] NULL,
	[ActionName] [varchar](100) NOT NULL,
	[PageName] [varchar](50) NOT NULL,
	[IPAddress] [varchar](20) NOT NULL,
	[RequestDateTime] [datetime] NOT NULL,
	[RequestParameters] [varchar](max) NULL,
 CONSTRAINT [PK_IQLog_UserActions] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)
) ON [PRIMARY]