ALTER TABLE [dbo].[ClientRole]
    ADD CONSTRAINT [DF_ClientRole_ModifiedBy] DEFAULT ('System') FOR [ModifiedBy];

