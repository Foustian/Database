ALTER TABLE [dbo].[CustomerRole]  WITH CHECK ADD  CONSTRAINT [FK_CustomerRole_Role] FOREIGN KEY([RoleID])
REFERENCES [dbo].[Role] ([RoleKey])
GO
ALTER TABLE [dbo].[CustomerRole] CHECK CONSTRAINT [FK_CustomerRole_Role]
GO