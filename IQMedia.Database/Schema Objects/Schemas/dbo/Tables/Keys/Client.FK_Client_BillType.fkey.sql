ALTER TABLE [dbo].[Client]  WITH CHECK ADD  CONSTRAINT [FK_Client_BillType] FOREIGN KEY([BillTypeID])
REFERENCES [dbo].[BillType] ([BillTypeKey])
GO
ALTER TABLE [dbo].[Client] CHECK CONSTRAINT [FK_Client_BillType]
GO