
ALTER TABLE [dbo].[IQAgentiFrame]  WITH CHECK ADD  CONSTRAINT [FK_IQAgentiFrame_IQAgentResults] FOREIGN KEY([IQAgentResultID])
REFERENCES [dbo].[IQAgentResults] ([IQAgentResultKey])


ALTER TABLE [dbo].[IQAgentiFrame] CHECK CONSTRAINT [FK_IQAgentiFrame_IQAgentResults]





