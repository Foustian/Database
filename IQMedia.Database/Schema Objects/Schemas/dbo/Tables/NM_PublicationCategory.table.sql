CREATE TABLE [dbo].[NM_PublicationCategory](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](250) NOT NULL,
	[Source_Rank] [int] NOT NULL,
	[Order_Number] [int] NOT NULL,
	[IsActive] [bit] NOT NULL
) ON [PRIMARY]