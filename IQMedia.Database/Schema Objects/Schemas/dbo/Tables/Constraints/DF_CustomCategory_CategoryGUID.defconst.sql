ALTER TABLE [dbo].[CustomCategory]
    ADD CONSTRAINT [DF_CustomCategory_CategoryGUID] DEFAULT (newid()) FOR [CategoryGUID];

