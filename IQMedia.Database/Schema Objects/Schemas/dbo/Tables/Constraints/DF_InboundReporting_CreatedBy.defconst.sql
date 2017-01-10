ALTER TABLE [dbo].[InboundReporting]
    ADD CONSTRAINT [DF_InboundReporting_CreatedBy] DEFAULT ('System') FOR [CreatedBy];

