ALTER TABLE [dbo].[IQ_News]
    ADD CONSTRAINT [DF_IQ_News_ModifiedDate] DEFAULT (getdate()) FOR [ModifiedDate];