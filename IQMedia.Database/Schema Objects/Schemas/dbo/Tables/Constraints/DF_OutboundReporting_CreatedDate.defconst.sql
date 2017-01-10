ALTER TABLE [dbo].[OutboundReporting]
    ADD CONSTRAINT [DF_OutboundReporting_CreatedDate] DEFAULT (getdate()) FOR [CreatedDate];

