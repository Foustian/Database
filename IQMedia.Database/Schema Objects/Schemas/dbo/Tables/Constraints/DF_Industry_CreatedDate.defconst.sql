ALTER TABLE [dbo].[Industry]
    ADD CONSTRAINT [DF_Industry_CreatedDate] DEFAULT (getdate()) FOR [CreatedDate];

