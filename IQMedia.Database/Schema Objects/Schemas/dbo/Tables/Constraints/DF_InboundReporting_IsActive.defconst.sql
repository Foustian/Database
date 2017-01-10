ALTER TABLE [dbo].[InboundReporting]
    ADD CONSTRAINT [DF_InboundReporting_IsActive] DEFAULT ((1)) FOR [IsActive];

