ALTER TABLE [dbo].[OutboundReporting]
    ADD CONSTRAINT [DF_OutboundReporting_CreatedBy] DEFAULT ('System') FOR [CreatedBy];

