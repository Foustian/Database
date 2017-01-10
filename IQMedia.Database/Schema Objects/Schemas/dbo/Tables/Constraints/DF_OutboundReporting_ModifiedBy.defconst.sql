ALTER TABLE [dbo].[OutboundReporting]
    ADD CONSTRAINT [DF_OutboundReporting_ModifiedBy] DEFAULT ('System') FOR [ModifiedBy];

