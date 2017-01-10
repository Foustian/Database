CREATE TABLE [dbo].[IQClipTimeSync_Data]
(
	[_ClipGuid] [uniqueidentifier] NOT NULL,
	[_TypeID] [int] NOT NULL,
	[Data] [varchar](max) NOT NULL,
	[DateCreated] [datetime] NULL,
	[IsActive] [bit] NULL,
 CONSTRAINT [PK_IQClipTimeSync_Data] PRIMARY KEY CLUSTERED 
(
	[_ClipGuid] ASC,
	[_TypeID] ASC
)
) ON [PRIMARY]
