CREATE PROCEDURE [dbo].[usp_services_ClipCCExport_IQService_ClipCCExport_SelectQueued]
(
	@TopRows int,
	@MachineName varchar(255)
)
AS
BEGIN
	
	;WITH CTE_ClipCCExport AS
	(
		SELECT TOP(@TopRows)
				ID
		FROM 
				IQService_ClipCCExport
		WHERE	
				[Status]='QUEUED'
		ORDER BY 
				LastModified DESC
	)

	UPDATE IQService_ClipCCExport
	SET
			[Status]='SELECT',
			[MachineName]=@MachineName
	FROM
			IQService_ClipCCExport
				INNER JOIN CTE_ClipCCExport
					ON	IQService_ClipCCExport.ID=CTE_ClipCCExport.ID
						AND	IQService_ClipCCExport.[Status]='QUEUED'

	SELECT 
			ID,
			_ClipGUID AS ClipGUID
	FROM
			IQService_ClipCCExport
	WHERE
			[Status]='SELECT'
		AND	[MachineName]=@MachineName
END