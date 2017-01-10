ALTER TABLE [dbo].[InboundReporting]
    ADD CONSTRAINT [DF_InboundReporting_CreatedDate] DEFAULT (getdate()) FOR [CreatedDate];

