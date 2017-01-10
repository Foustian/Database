ALTER TABLE [dbo].[InboundReporting]
    ADD CONSTRAINT [DF_InboundReporting_ModifiedDate] DEFAULT (getdate()) FOR [ModifiedDate];

