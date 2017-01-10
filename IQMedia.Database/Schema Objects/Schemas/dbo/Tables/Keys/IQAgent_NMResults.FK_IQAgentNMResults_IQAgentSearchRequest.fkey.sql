ALTER TABLE [dbo].[IQAgent_NMResults]  WITH CHECK ADD  CONSTRAINT [FK_IQAgentNMResults_IQAgentSearchRequest] FOREIGN KEY([IQAgentSearchRequestID])
REFERENCES [dbo].[IQAgent_SearchRequest] ([ID])
GO

ALTER TABLE [dbo].[IQAgent_NMResults] CHECK CONSTRAINT [FK_IQAgentNMResults_IQAgentSearchRequest]
GO
