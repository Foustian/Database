ALTER TABLE [dbo].[BillFrequency]
    ADD CONSTRAINT [DF_BillFrequency_CreatedBy] DEFAULT ('System') FOR [CreatedBy];

