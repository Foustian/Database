ALTER TABLE [dbo].[IQSolrEngines]
   ADD CONSTRAINT [DF_IQSolrEngines_CreatedDate] 
   DEFAULT getdate()
   FOR [CreatedDate]


