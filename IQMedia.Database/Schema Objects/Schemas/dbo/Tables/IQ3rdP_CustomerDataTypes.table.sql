CREATE TABLE [dbo].[IQ3rdP_CustomerDataTypes](
	[_CustomerGuid] [uniqueidentifier] NOT NULL,
	[_DataTypeID] [int] NOT NULL,
	[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_IQ3rdP_CustomerDataTypes_CreatedDate]  DEFAULT (getdate())
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[IQ3rdP_CustomerDataTypes]  WITH CHECK ADD  CONSTRAINT [FK_IQ3rdP_CustomerDataTypes_DataTypeID] FOREIGN KEY([_DataTypeID])
REFERENCES [dbo].[IQ3rdP_DataTypes] ([ID])
GO

ALTER TABLE [dbo].[IQ3rdP_CustomerDataTypes] CHECK CONSTRAINT [FK_IQ3rdP_CustomerDataTypes_DataTypeID]
GO

