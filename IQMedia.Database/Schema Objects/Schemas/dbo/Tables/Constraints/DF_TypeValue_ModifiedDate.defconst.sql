ALTER TABLE [dbo].[TypeValue]
    ADD CONSTRAINT [DF_TypeValue_ModifiedDate] DEFAULT (getdate()) FOR [ModifiedDate];

