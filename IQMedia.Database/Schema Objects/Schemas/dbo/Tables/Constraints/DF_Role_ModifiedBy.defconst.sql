ALTER TABLE [dbo].[Role]
    ADD CONSTRAINT [DF_Role_ModifiedBy] DEFAULT ('System') FOR [ModifiedBy];

