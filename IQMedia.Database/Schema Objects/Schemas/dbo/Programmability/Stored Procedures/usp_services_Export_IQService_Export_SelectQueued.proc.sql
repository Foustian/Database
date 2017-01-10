CREATE PROCEDURE [dbo].[usp_services_Export_IQService_Export_SelectQueued]
(
	@TopRows int,
	@MachineName varchar(255)
)
AS
BEGIN
	
	;WITH CTE_Export AS
	(
		SELECT TOP(@TopRows)
				ID
		FROM 
				IQService_Export
		WHERE	
				[Status]='QUEUED'
		ORDER BY 
				LastModified DESC,
				[Priority] ASC
	)

	UPDATE IQService_Export
	SET
			[Status]='SELECT',
			[MachineName]=@MachineName
	FROM
			IQService_Export
				INNER JOIN CTE_Export
					ON		IQService_Export.ID=CTE_Export.ID
						AND	IQService_Export.[Status]='QUEUED'

	SELECT 
			ID,
			ClipGuid,
			OutputExt,
			OutputPath,
			OutputDimensions
	FROM
			IQService_Export
	WHERE
			[Status]='SELECT'
		AND	[MachineName]=@MachineName
END