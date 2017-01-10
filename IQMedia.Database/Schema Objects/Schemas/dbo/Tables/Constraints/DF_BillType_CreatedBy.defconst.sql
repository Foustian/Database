ALTER TABLE [dbo].[BillType]
    ADD CONSTRAINT [DF_BillType_CreatedBy] DEFAULT ('System') FOR [CreatedBy];

