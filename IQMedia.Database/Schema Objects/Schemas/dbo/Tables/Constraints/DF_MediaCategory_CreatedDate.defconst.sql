ALTER TABLE [dbo].[MediaCategory]
    ADD CONSTRAINT [DF_MediaCategory_CreatedDate] DEFAULT (getdate()) FOR [CreatedDate];

