CREATE TABLE [dbo].[IQAgent_SearchRequest]
(
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ClientGUID] [uniqueidentifier] NULL,
	[Query_Name] [varchar](max) NULL,
	[Query_Version] [int] NULL,
	[SearchTerm] [xml] NULL,
	[_CustomerSavedSearchID] [bigint] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedDate] [datetime] NULL,
	[CreatedBy] [varchar](150) NULL,
	[ModifiedBy] [varchar](150) NULL,
	[IsActive] [bit] NULL,
	[v4SearchTerm] [xml] NULL
)
