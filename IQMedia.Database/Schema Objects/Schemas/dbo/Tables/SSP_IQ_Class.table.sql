CREATE TABLE [dbo].[SSP_IQ_Class](
	[SSP_IQ_ClassKey] [int] IDENTITY(1,1) NOT NULL,
	[IQ_Class] [varchar](13) NOT NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedDate] [datetime] NULL,
	[CreatedBy] [varchar](50) NULL,
	[ModifiedBy] [varchar](50) NULL,
	[IsActive] [bit] NULL,
	[IQ_Class_Num] [varchar](2) NULL
) ON [PRIMARY]