ALTER TABLE [dbo].[CustomerRole]
    ADD CONSTRAINT [DF_CustomerRole_CreatedDate] DEFAULT (getdate()) FOR [CreatedDate];

