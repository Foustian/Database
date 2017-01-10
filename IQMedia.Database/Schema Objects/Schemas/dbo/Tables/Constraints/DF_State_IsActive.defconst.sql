ALTER TABLE [dbo].[State]
    ADD CONSTRAINT [DF_State_IsActive] DEFAULT ((1)) FOR [IsActive];

