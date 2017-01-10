ALTER TABLE [dbo].[Client]  WITH CHECK ADD  CONSTRAINT [FK_Client_State] FOREIGN KEY([StateID])
REFERENCES [dbo].[State] ([StateKey])
GO
ALTER TABLE [dbo].[Client] CHECK CONSTRAINT [FK_Client_State]
GO