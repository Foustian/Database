ALTER TABLE [dbo].[MediaCategory]
    ADD CONSTRAINT [DF_MediaCategory_CreatedBy] DEFAULT ('System') FOR [CreatedBy];

