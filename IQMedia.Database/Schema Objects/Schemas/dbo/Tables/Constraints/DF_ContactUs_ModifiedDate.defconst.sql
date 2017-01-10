ALTER TABLE [dbo].[ContactUs]
    ADD CONSTRAINT [DF_ContactUs_ModifiedDate] DEFAULT (getdate()) FOR [ModifiedDate];

