ALTER TABLE [dbo].[CustomerRole]  WITH CHECK ADD  CONSTRAINT [FK_CustomerRole_Customer] FOREIGN KEY([CustomerID])
REFERENCES [dbo].[Customer] ([CustomerKey])
GO
ALTER TABLE [dbo].[CustomerRole] CHECK CONSTRAINT [FK_CustomerRole_Customer]
GO