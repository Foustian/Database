CREATE TABLE [dbo].[fliQ_Exception]
(
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Exception] [varchar](max) NOT NULL,
	[_Fliq_CustomerGuid] [uniqueidentifier] NULL,
	[Application] [varchar](155) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[IsActive] [bit] NOT NULL,
	CONSTRAINT [PK_fliq_Exception] PRIMARY KEY CLUSTERED ([ID] ASC)
) ON [PRIMARY]
