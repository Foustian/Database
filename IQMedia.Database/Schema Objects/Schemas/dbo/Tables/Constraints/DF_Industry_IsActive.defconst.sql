ALTER TABLE [dbo].[Industry]
    ADD CONSTRAINT [DF_Industry_IsActive] DEFAULT ((1)) FOR [IsActive];

