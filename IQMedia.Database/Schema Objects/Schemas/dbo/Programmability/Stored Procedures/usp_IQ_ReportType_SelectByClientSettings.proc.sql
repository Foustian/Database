CREATE PROCEDURE [dbo].[usp_IQ_ReportType_SelectByClientSettings]
	@ClientGuid uniqueidentifier,
	@MasterReportType varchar(50)
AS
BEGIN
	DECLARE @ReportIDs varchar(max)
	DECLARE @Query nvarchar(max)
	SELECT @ReportIDs = ISNULL((SELECT IQClient_CustomSettings.Value From IQClient_CustomSettings WHERE _ClientGuid = @ClientGuid AND Field ='ReportTypeSettings'),(SELECT IQClient_CustomSettings.Value FROM IQClient_CustomSettings WHERE _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AND Field ='ReportTypeSettings'))
	SET @Query =	'SELECT 
						Convert(varchar(10),IQ_ReportType.ID) + '','' + IQ_ReportType.[Identity] as ReportIdentity,
						IQ_ReportType.ID,
						IQ_ReportType.Name
					FROM 
						IQ_ReportType
					WHERE
						IQ_ReportType.ID in ('+CASE WHEN @ReportIDs IS NULL THEN '0' ELSE @ReportIDs END+')
						AND IQ_ReportType.MasterReportType = '''+@MasterReportType+'''';
	PRINT @Query
	EXEC sp_executesql @Query
END