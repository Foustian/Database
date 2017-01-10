CREATE PROCEDURE [dbo].[usp_v4_IQ_Report_SelectFolderByClientGuid]
	@ClientGuid uniqueidentifier
AS
BEGIN

	DECLARE @ReportTypeID AS BIGINT
	
	SELECT @ReportTypeID = ID FROM IQ_ReportType WHERE [Identity] = 'v4Library'

	SELECT
			ID,
			Name as [text],
			'Folder' as [Type],
			_ParentID as parent
	FROM 
			IQReport_Folder
	Where
			_ClientGUID  = @ClientGuid
			and IsActive = 1
	union all 
	SELECT
		ID,
		Title as [text],
		'File' as [Type],
		_FolderID as parent
	FROM
		IQ_Report
	WHERE
		ClientGuid = @ClientGuid
		and IsActive = 1
		AND _ReportTypeID = @ReportTypeID
	order by [Type] desc,[text]
END