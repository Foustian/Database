ALTER TABLE [dbo].[Industry]
    ADD CONSTRAINT [DF_Industry_ModifiedDate] DEFAULT (getdate()) FOR [ModifiedDate];

