CREATE TABLE [dbo].[MentionReport]
(
	[ID]		BIGINT		IDENTITY (1, 1) NOT NULL,
	ReportXml	xml		NOT NULL,	
	IsActive	bit		NULL
)
GO 

alter table [MentionReport] add constraint df_MentionReportIsActive default 1 for IsActive