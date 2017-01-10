ALTER TABLE [dbo].[IQAgent_TwitterResults]  WITH CHECK ADD  CONSTRAINT [FK_IQAgentTwitterResults_IQAgentSearchRequest] FOREIGN KEY([IQAgentSearchRequestID])
REFERENCES [dbo].[IQAgent_SearchRequest] ([ID])
GO
ALTER TABLE [dbo].[IQAgent_TwitterResults] CHECK CONSTRAINT [FK_IQAgentTwitterResults_IQAgentSearchRequest]
GO