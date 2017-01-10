ALTER TABLE [dbo].[Customer]  WITH CHECK ADD  CONSTRAINT [FK_Customer_Client] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Client] ([ClientKey])
GO
ALTER TABLE [dbo].[Customer] CHECK CONSTRAINT [FK_Customer_Client]
GO