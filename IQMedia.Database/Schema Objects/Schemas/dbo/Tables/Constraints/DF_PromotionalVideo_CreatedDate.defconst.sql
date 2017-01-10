ALTER TABLE [dbo].[PromotionalVideo]
    ADD CONSTRAINT [DF_PromotionalVideo_CreatedDate] DEFAULT (getdate()) FOR [CreatedDate];

