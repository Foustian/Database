CREATE TABLE [dbo].[PricingCode](
	[PricingCodeKey] [bigint] IDENTITY(1,1) NOT NULL,
	[Pricing_Code] [varchar](3) NULL,
	[Pricing_Code_Description] [varchar](50) NULL,
	[CreatedDate] [datetime] NULL,
	[CreatedBy] [varchar](50) NULL,
	[ModifiedDate] [datetime] NULL,
	[ModifiedBy] [varchar](50) NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]