ALTER TABLE [dbo].[MediaCategory]
    ADD CONSTRAINT [DF_MediaCategory_ModifiedDate] DEFAULT (getdate()) FOR [ModifiedDate];

