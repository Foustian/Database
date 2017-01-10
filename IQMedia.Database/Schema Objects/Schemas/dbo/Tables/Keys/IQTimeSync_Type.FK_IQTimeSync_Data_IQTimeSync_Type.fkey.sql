ALTER TABLE [dbo].[IQTimeSync_Data]  WITH CHECK ADD  CONSTRAINT [FK_IQTimeSync_Data_IQTimeSync_Type] FOREIGN KEY([_TypeID])
REFERENCES [dbo].[IQTimeSync_Type] ([ID])