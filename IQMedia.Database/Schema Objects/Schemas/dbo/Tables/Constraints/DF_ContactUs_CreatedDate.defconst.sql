ALTER TABLE [dbo].[ContactUs]
    ADD CONSTRAINT [DF_ContactUs_CreatedDate] DEFAULT (getdate()) FOR [CreatedDate];

