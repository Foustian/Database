ALTER TABLE [dbo].[ClientRole]
    ADD CONSTRAINT [DF_ClientRole_CreatedBy] DEFAULT ('System') FOR [CreatedBy];

