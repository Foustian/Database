ALTER TABLE [dbo].[CustomCategory]
    ADD CONSTRAINT [DF_CustomCategory_IsActive] DEFAULT ((1)) FOR [IsActive];

