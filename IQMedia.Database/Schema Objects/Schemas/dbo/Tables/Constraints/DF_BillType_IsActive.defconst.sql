ALTER TABLE [dbo].[BillType]
    ADD CONSTRAINT [DF_BillType_IsActive] DEFAULT ((1)) FOR [IsActive];

