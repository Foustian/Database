ALTER TABLE [dbo].[OutboundReporting]
    ADD CONSTRAINT [DF_OutboundReporting_IsActive] DEFAULT ((1)) FOR [IsActive];

