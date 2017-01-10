ALTER TABLE [dbo].[Industry]
    ADD CONSTRAINT [DF_Industry_ModifiedBy] DEFAULT ('System') FOR [ModifiedBy];

