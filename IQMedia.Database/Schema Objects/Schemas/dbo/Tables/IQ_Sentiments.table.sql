CREATE TABLE [dbo].[IQ_Sentiments]
(
	[Word] [varchar](50) NOT NULL,
	[Category] [varchar](50) NOT NULL,
	[Value] [int] NOT NULL,
	[_ClientGuid] uniqueidentifier NULL
) ON [PRIMARY]
