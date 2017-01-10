ALTER TABLE [dbo].[IQCore_Source]  WITH CHECK ADD  CONSTRAINT [FK_IQCore_Source_IQCore_Timezone] FOREIGN KEY([_TimezoneID])
REFERENCES [dbo].[IQCore_Timezone] ([ID])
GO
ALTER TABLE [dbo].[IQCore_Source] CHECK CONSTRAINT [FK_IQCore_Source_IQCore_Timezone]
GO