ALTER TABLE [dbo].[TypeValue]
    ADD CONSTRAINT [DF_TypeValue_IsActive] DEFAULT ((1)) FOR [IsActive];

