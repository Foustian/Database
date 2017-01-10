ALTER TABLE [dbo].[PromotionalVideo]
    ADD CONSTRAINT [DF_PromotionalVideo_ModifiedDate] DEFAULT (getdate()) FOR [ModifiedDate];

