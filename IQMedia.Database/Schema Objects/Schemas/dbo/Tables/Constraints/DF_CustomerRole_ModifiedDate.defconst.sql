ALTER TABLE [dbo].[CustomerRole]
    ADD CONSTRAINT [DF_CustomerRole_ModifiedDate] DEFAULT (getdate()) FOR [ModifiedDate];

