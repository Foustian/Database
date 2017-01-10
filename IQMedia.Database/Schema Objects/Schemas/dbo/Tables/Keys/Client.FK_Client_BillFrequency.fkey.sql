ALTER TABLE [dbo].[Client]  WITH CHECK ADD  CONSTRAINT [FK_Client_BillFrequency] FOREIGN KEY([BillFrequencyID])
REFERENCES [dbo].[BillFrequency] ([BillFrequencyKey])
GO
ALTER TABLE [dbo].[Client] CHECK CONSTRAINT [FK_Client_BillFrequency]
GO