ALTER TABLE [dbo].[Industry]
    ADD CONSTRAINT [DF_Industry_CreatedBy] DEFAULT ('System') FOR [CreatedBy];

