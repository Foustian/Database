ALTER TABLE [dbo].[BillFrequency]
    ADD CONSTRAINT [DF_BillFrequency_IsActive] DEFAULT ((1)) FOR [IsActive];

