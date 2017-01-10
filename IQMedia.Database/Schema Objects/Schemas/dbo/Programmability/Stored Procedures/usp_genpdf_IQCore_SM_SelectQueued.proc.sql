CREATE PROCEDURE [dbo].[usp_genpdf_IQCore_SM_SelectQueued]
	@TopRows int,
	@MachineName varchar(255)
AS
BEGIN
	;WITH TempIQCore_SM AS
	(
		SELECT TOP(@TopRows)
				ArticleID
		FROM
				IQCore_SM
		WHERE 
				[Status] = 'QUEUED'
		ORDER BY 
				LastModified desc
	)

	UPDATE 
			IQCore_SM
	SET
			[Status] = 'SELECT',
			MachineName = @MachineName
	FROM 
			IQCore_SM
				INNER JOIN TempIQCore_SM 
				ON IQCore_SM.ArticleID = TempIQCore_SM.ArticleID
				AND IQCore_SM.[Status] = 'QUEUED'

	SELECT
			ArticleID,
			Url,
			Harvest_Time,
			_RootPathID
	FROM
			IQCore_SM
	WHERE
			[Status] = 'SELECT'
			AND MachineName = @MachineName

END