ALTER TABLE [dbo].[Client]  WITH CHECK ADD  CONSTRAINT [FK_Client_PricingCode] FOREIGN KEY([PricingCodeID])
REFERENCES [dbo].[PricingCode] ([PricingCodeKey])
GO
ALTER TABLE [dbo].[Client] CHECK CONSTRAINT [FK_Client_PricingCode]
GO