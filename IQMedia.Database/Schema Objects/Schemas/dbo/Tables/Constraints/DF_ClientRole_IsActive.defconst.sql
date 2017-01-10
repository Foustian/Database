ALTER TABLE [dbo].[ClientRole]
    ADD CONSTRAINT [DF_ClientRole_IsActive] DEFAULT ((1)) FOR [IsActive];

