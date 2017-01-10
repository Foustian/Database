ALTER TABLE [dbo].[NM_NewsCategory]
    ADD CONSTRAINT [DF_NB_NewsCategory_IsActive] DEFAULT ((1)) FOR [IsActive];

