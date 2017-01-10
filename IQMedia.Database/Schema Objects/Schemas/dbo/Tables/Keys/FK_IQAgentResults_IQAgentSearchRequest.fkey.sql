ALTER TABLE [dbo].[IQAgentResults]
    ADD CONSTRAINT [FK_IQAgentResults_IQAgentSearchRequest] FOREIGN KEY ([SearchRequestID]) REFERENCES [dbo].[IQAgentSearchRequest] ([SearchRequestKey]) ON DELETE NO ACTION ON UPDATE NO ACTION;

