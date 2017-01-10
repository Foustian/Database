CREATE TABLE [dbo].[IQSession]
(
	[SessionID] VARCHAR(255) NOT NULL, 
	[LoginID] VARCHAR(255) NOT NULL,
	[SessionTimeOut] DATETIME NOT NULL,
	[LastAccessTime] DATETIME NOT NULL,
	[Server] VARCHAR(16) NULL
)
