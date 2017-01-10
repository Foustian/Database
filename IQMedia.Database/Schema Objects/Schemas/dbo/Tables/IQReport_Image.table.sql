CREATE TABLE [dbo].[IQClient_CustomImage]
(
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[_ClientGUID] [uniqueidentifier] NOT NULL,
	[Location] [varchar](255) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsDefault] [bit] NULL,
	[IsDefaultEmail] [bit] NULL,
	[ModifiedDate] [datetime] NULL,
	CONSTRAINT [PK_IQReport_Image] PRIMARY KEY CLUSTERED (
	[ID] ASC ) ON [PRIMARY]
) ON [PRIMARY]


GO
ALTER TABLE [dbo].[IQClient_CustomImage] ADD  CONSTRAINT [DF_IQReport_Image_IsActive]  DEFAULT ((1)) FOR [IsActive]
