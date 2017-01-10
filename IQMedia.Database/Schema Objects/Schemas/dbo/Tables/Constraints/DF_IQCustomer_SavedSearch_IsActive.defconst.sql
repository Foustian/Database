ALTER TABLE [dbo].[IQCustomer_SavedSearch]
    ADD CONSTRAINT [DF_IQCustomer_SavedSearch_IsActive] DEFAULT ((1)) FOR [IsActive];

