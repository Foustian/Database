﻿ALTER TABLE [dbo].[IQ_Five_Min_Staging] ADD  CONSTRAINT [IX_IQ_FiveMS] UNIQUE NONCLUSTERED 
(
	[IQ_FiveMS_Key] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO


