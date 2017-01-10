ALTER TABLE [dbo].[IQAgent_SearchRequest]
	ADD CONSTRAINT [FK_IQAgent_SearchRequest_IQCustomer_SavedSearch] 
	FOREIGN KEY (_CustomerSavedSearchID)
	REFERENCES IQCustomer_SavedSearch (ID)	

