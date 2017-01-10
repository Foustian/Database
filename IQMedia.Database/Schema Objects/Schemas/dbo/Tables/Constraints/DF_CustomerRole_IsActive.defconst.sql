ALTER TABLE [dbo].[CustomerRole]
    ADD CONSTRAINT [DF_CustomerRole_IsActive] DEFAULT ((1)) FOR [IsActive];

