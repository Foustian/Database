CREATE TABLE [dbo].[IQClient_StationSharing]
(
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ClientGUID] [uniqueidentifier] NOT NULL,
	[IQ_Station_ID] [varchar](255) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[DateModified] [datetime] NOT NULL,
	[IsActive] [bit] NOT NULL
)
