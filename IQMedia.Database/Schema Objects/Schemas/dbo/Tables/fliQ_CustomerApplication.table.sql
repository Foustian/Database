CREATE TABLE [dbo].[fliQ_CustomerApplication](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[_FliqCustomerGUID] [uniqueidentifier] NOT NULL,
	[_FliqApplicationID] [bigint] NOT NULL,
	[UniqueID] [uniqueidentifier] NOT NULL,
	[HasMobileRegd] [bit] NOT NULL,
	[DateMobileRegd] [datetime] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[DateModified] [datetime] NOT NULL
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[fliQ_CustomerApplication] ADD  CONSTRAINT [DF_fliQ_CustomerApplication_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO

ALTER TABLE [dbo].[fliQ_CustomerApplication] ADD  CONSTRAINT [DF_fliQ_CustomerApplication_DateModified]  DEFAULT (getdate()) FOR [DateModified]