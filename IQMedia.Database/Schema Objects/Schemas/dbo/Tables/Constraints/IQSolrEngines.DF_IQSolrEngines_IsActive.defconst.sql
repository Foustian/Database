ALTER TABLE [dbo].[IQSolrEngines]
   ADD CONSTRAINT [DF_IQSolrEngines_IsActive] 
   DEFAULT ((1))
   FOR [IsActive]


