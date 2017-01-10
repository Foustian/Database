ALTER TABLE [dbo].[TypeValue]
    ADD CONSTRAINT [DF_TypeValue_CreatedDate] DEFAULT (getdate()) FOR [CreatedDate];

