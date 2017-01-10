ALTER TABLE [dbo].[Type]
    ADD CONSTRAINT [DF_Type_ModifiedDate] DEFAULT (getdate()) FOR [ModifiedDate];

