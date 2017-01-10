CREATE TABLE [dbo].[SSP_Station_Affil](
	[SSP_Station_AffilKey] [int] IDENTITY(1,1) NOT NULL,
	[Station_Affil] [varchar](40) NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedDate] [datetime] NULL,
	[CreatedBy] [varchar](50) NULL,
	[ModifiedBy] [varchar](50) NULL,
	[IsActive] [bit] NULL,
	[Station_Affil_Num] [varchar](2) NULL
) ON [PRIMARY]