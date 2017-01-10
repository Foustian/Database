ALTER TABLE [dbo].[Role]
    ADD CONSTRAINT [DF_Role_CreatedBy] DEFAULT ('System') FOR [CreatedBy];

