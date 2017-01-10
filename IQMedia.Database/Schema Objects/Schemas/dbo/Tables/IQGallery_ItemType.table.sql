CREATE TABLE [dbo].[IQGallery_ItemType]
(
	[ID] [tinyint] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[Description] [varchar](255) NOT NULL,
	[Width] [int] NOT NULL,
	[Height] [int] NOT NULL,
	[IsActive] [bit] NULL,
 CONSTRAINT [PK_IQGallery_ItemType] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
SET IDENTITY_INSERT [dbo].[IQGallery_ItemType] ON
INSERT [dbo].[IQGallery_ItemType] ([ID], [Name], [Description], [Width], [Height], [IsActive]) VALUES (1, N'TVBlock', N'TV Block', 4, 4, 1)
INSERT [dbo].[IQGallery_ItemType] ([ID], [Name], [Description], [Width], [Height], [IsActive]) VALUES (2, N'HorizontalTextBlock', N'Horizontal Text Block', 4, 2, 1)
INSERT [dbo].[IQGallery_ItemType] ([ID], [Name], [Description], [Width], [Height], [IsActive]) VALUES (3, N'VerticalTextBlock', N'Vertical Text Block', 2, 4, 1)
SET IDENTITY_INSERT [dbo].[IQGallery_ItemType] OFF