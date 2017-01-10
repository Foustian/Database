ALTER TABLE [dbo].[ContactUs]
    ADD CONSTRAINT [DF_ContactUs_IsActive] DEFAULT ((1)) FOR [IsActive];

