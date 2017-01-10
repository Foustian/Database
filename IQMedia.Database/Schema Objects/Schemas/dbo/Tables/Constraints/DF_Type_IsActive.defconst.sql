ALTER TABLE [dbo].[Type]
    ADD CONSTRAINT [DF_Type_IsActive] DEFAULT ((1)) FOR [IsActive];

