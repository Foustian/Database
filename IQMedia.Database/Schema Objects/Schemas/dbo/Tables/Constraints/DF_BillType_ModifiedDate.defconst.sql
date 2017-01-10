ALTER TABLE [dbo].[BillType]
    ADD CONSTRAINT [DF_BillType_ModifiedDate] DEFAULT (getdate()) FOR [ModifiedDate];

