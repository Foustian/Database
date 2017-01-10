ALTER TABLE [dbo].[IQRegion]
    ADD CONSTRAINT [DF_IQRegion_IsActive] DEFAULT ((1)) FOR [IsActive];

