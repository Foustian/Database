ALTER TABLE [dbo].[PromotionalVideo]
    ADD CONSTRAINT [DF_PromotionalVideo_IsActive] DEFAULT ((1)) FOR [IsActive];

