ALTER TABLE [dbo].[Role]
    ADD CONSTRAINT [DF_Role_CreatedDate] DEFAULT (getdate()) FOR [CreatedDate];

