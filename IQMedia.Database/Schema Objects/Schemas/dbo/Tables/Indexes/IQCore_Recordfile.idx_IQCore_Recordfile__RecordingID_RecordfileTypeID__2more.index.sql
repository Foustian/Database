CREATE NONCLUSTERED INDEX [idx_IQCore_Recordfile__RecordingID_RecordfileTypeID__2more] ON [dbo].[IQCore_Recordfile] 
(
	[_RecordingID] ASC,
	[_RecordfileTypeID] ASC
)
INCLUDE ( [Guid],
[Status]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO