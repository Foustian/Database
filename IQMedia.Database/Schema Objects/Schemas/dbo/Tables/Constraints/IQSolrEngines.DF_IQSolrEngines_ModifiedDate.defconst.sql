ALTER TABLE [dbo].[IQSolrEngines]
   ADD CONSTRAINT [DF_IQSolrEngines_ModifiedDate] 
   DEFAULT getdate()
   FOR [ModifiedDate]


