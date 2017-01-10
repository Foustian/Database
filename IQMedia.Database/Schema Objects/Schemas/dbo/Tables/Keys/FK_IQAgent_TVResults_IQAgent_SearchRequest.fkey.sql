ALTER TABLE [dbo].[IQAgent_TVResults]  WITH CHECK ADD  CONSTRAINT [FK_IQAgent_TVResults_IQAgent_SearchRequest] FOREIGN KEY([SearchRequestID])
REFERENCES [dbo].[IQAgent_SearchRequest] ([ID])