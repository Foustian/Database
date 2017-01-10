ALTER TABLE [dbo].[Type]
    ADD CONSTRAINT [DF_Type_CreatedDate] DEFAULT (getdate()) FOR [CreatedDate];

