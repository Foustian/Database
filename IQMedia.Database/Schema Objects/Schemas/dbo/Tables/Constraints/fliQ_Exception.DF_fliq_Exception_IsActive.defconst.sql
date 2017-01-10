ALTER TABLE [dbo].[fliQ_Exception]
   ADD CONSTRAINT [DF_fliq_Exception_IsActive] 
   DEFAULT ((1))
   FOR [IsActive]


