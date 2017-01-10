ALTER TABLE [dbo].[MediaCategory]
    ADD CONSTRAINT [DF_MediaCategory_IsActive] DEFAULT ((1)) FOR [IsActive];

