﻿ALTER TABLE [dbo].[IQUGCArchive]
    ADD CONSTRAINT [PK_IQUGCArchive] PRIMARY KEY CLUSTERED 
(
	[IQUGCArchiveKey] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]

