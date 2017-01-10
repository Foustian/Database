CREATE TABLE [dbo].[IQTrack_LicenseClick](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[_CustomerGUID] [uniqueidentifier] NOT NULL,
	[MOURL] [varchar](500) NOT NULL,
	[Event] [varchar](50) NOT NULL,
	[DateModified] [datetime] NOT NULL,
	[IQLicense]    [tinyint]  Null,
 CONSTRAINT [PK_IQTrack_NRClick] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]