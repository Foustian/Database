ALTER TABLE [dbo].[BillFrequency]
    ADD CONSTRAINT [DF_BillFrequency_CreatedDate] DEFAULT (getdate()) FOR [CreatedDate];

