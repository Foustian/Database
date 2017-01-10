CREATE TABLE [dbo].[IQAgent_EmailDigest](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[AgentXml] [xml] NOT NULL,
	[TimeOfDay] [time](7) NOT NULL,
	[EmailAddress] [varchar](max) NOT NULL,
	[_ReportImageID] [bigint] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_IQAgent_EmailDigest] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]