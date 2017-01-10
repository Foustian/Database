ALTER TABLE [dbo].[Role]
    ADD CONSTRAINT [DF_Role_IsActive] DEFAULT ((1)) FOR [IsActive];

