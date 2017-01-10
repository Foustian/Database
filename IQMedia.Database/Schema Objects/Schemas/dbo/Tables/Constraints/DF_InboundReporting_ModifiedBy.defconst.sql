ALTER TABLE [dbo].[InboundReporting]
    ADD CONSTRAINT [DF_InboundReporting_ModifiedBy] DEFAULT ('System') FOR [ModifiedBy];

