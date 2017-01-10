ALTER TABLE [dbo].[IQ_News]
    ADD CONSTRAINT [DF_IQ_News_CreatedDate] DEFAULT (getdate()) FOR [CreatedDate];