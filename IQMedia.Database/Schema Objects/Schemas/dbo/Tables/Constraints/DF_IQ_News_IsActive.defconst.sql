ALTER TABLE [dbo].[IQ_News]
    ADD CONSTRAINT [DF_IQ_News_IsActive] DEFAULT ((1)) FOR [IsActive];