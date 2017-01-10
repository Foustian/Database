CREATE TABLE [dbo].[IQDataImport_Clients](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[_ClientGuid] [uniqueidentifier] NOT NULL,
	[ViewPath] [varchar](100) NOT NULL,
	[GetResultsMethod] [varchar](100) NOT NULL,
	[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_IQDataImport_Clients_CreatedDate]  DEFAULT (getdate()),
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_IQDataImport_Clients_ModifiedDate]  DEFAULT (getdate()),
	[IsActive] [bit] NOT NULL CONSTRAINT [DF_IQDataImport_Clients_IsActive]  DEFAULT ((1)),
 CONSTRAINT [PK_IQDataImport_Clients] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO