CREATE PROCEDURE [dbo].[usp_genpdf_IQCore_NM_SelectQueued]
	@TopRows int,
	@MachineName varchar(255)
AS
BEGIN
	;WITH TempIQCore_NM AS
	(
		SELECT TOP(@TopRows)
				ArticleID
		FROM
				IQCore_NM	
		WHERE 
				[Status] = 'QUEUED'
		ORDER BY
				LastModified Desc
	)

	UPDATE 
			IQCore_NM 
	SET
			[Status] = 'SELECT',
			MachineName = @MachineName
	FROM 
			IQCore_NM
				INNER JOIN TempIQCore_NM 
				ON IQCore_NM.ArticleID = TempIQCore_NM.ArticleID
				AND IQCore_NM.[Status] = 'QUEUED'

	SELECT	
			ArticleID,
			Url,
			Harvest_Time,
			_RootPathID
	FROM
			IQCore_NM
	WHERE
			[Status] = 'SELECT'
			AND MachineName = @MachineName

END