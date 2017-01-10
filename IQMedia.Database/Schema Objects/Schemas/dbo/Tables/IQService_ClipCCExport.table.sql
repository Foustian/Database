CREATE TABLE [dbo].[IQService_ClipCCExport]
(
	[ID]	[UNIQUEIDENTIFIER] NOT NULL, 
	[_ClipGUID]	[UNIQUEIDENTIFIER] NOT NULL,
	[Status]	[VARCGAR(50)] NOT NULL,
	[DateQueued]	[DATETIME2(7)] NOT NULL,
	[LastModified]	[DATETIME2(7)]	NOT NULL,
	[MachineName]	[VARCHAR(255)]	NULL
)
