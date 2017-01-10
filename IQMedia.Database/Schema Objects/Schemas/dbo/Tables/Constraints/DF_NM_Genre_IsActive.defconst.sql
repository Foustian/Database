ALTER TABLE [dbo].[NM_Genre]
    ADD CONSTRAINT [DF_NM_Genre_IsActive] DEFAULT ((1)) FOR [IsActive];

