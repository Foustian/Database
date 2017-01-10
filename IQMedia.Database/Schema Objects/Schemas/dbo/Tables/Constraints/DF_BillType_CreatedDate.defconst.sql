ALTER TABLE [dbo].[BillType]
    ADD CONSTRAINT [DF_BillType_CreatedDate] DEFAULT (getdate()) FOR [CreatedDate];

