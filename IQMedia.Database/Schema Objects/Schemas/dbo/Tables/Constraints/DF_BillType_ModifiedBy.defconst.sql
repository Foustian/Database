ALTER TABLE [dbo].[BillType]
    ADD CONSTRAINT [DF_BillType_ModifiedBy] DEFAULT ('System') FOR [ModifiedBy];

