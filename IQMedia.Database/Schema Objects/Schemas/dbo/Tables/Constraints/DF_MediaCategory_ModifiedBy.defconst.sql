ALTER TABLE [dbo].[MediaCategory]
    ADD CONSTRAINT [DF_MediaCategory_ModifiedBy] DEFAULT ('System') FOR [ModifiedBy];

