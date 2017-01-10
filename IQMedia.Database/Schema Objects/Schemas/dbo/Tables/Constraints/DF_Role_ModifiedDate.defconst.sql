ALTER TABLE [dbo].[Role]
    ADD CONSTRAINT [DF_Role_ModifiedDate] DEFAULT (getdate()) FOR [ModifiedDate];

