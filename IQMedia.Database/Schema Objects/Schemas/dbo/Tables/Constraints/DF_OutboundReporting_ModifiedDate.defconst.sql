ALTER TABLE [dbo].[OutboundReporting]
    ADD CONSTRAINT [DF_OutboundReporting_ModifiedDate] DEFAULT (getdate()) FOR [ModifiedDate];

