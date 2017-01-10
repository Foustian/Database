ALTER TABLE [dbo].[Client]  WITH CHECK ADD  CONSTRAINT [FK_Client_Industry] FOREIGN KEY([IndustryID])
REFERENCES [dbo].[Industry] ([IndustryKey])
GO
ALTER TABLE [dbo].[Client] CHECK CONSTRAINT [FK_Client_Industry]
GO