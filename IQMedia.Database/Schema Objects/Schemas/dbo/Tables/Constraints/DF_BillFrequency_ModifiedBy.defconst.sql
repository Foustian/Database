ALTER TABLE [dbo].[BillFrequency]
    ADD CONSTRAINT [DF_BillFrequency_ModifiedBy] DEFAULT ('System') FOR [ModifiedBy];

