CREATE PROCEDURE [dbo].[usp_coresvc_RecordFile_SelectByRPID]
(
	@RPID	INT,
	@FromDate	DATETIME2(7),
	@ToDate	DATETIME2(7),
	@NumRecords	INT
)
AS
BEGIN

	SET NOCOUNT ON;

	SELECT
			TOP(@NumRecords)
			[RF].[Guid],
			[RP].[StoragePath],
			[RF].[Location],
			[RF].[Status]
	FROM
			[IQCore_Recordfile] AS RF WITH(NOLOCK)
				INNER JOIN [IQCore_Recording] AS REC WITH(NOLOCK)
					ON	[RF].[_RecordingID] = [REC].ID
				INNER JOIN [IQCore_RootPath] AS RP WITH(NOLOCK)
					ON	[RF].[_RootPathID] = [RP].[ID]
					AND	[RP].[ID] = @RPID
				LEFT OUTER JOIN [IQMove_Media] AS MOV WITH(NOLOCK)
					ON	[RF].[Guid] = [MOV].[_RecordFileGUID]
					AND	[MOV].[OriginRPID] = @RPID
	WHERE
			[RF].[Status] != 'DELETED'
		AND	[REC].[StartDate] >= @FromDate
		AND	[REC].[StartDate] <= @ToDate
		AND	[MOV].ID IS NULL


ENd