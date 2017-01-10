ALTER TABLE [dbo].[PricingCode]
    ADD CONSTRAINT [DF_PricingCode_IsActive] DEFAULT ((1)) FOR [IsActive];

