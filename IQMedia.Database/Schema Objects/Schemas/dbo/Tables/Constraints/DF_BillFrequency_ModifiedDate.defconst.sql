ALTER TABLE [dbo].[BillFrequency]
    ADD CONSTRAINT [DF_BillFrequency_ModifiedDate] DEFAULT (getdate()) FOR [ModifiedDate];

