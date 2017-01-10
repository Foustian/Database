ALTER TABLE [dbo].[NM_Region]
    ADD CONSTRAINT [DF_NB_Region_IsActive] DEFAULT ((1)) FOR [IsActive];

