CREATE PROCEDURE [dbo].[usp_services_ThumbGen_IQService_ThumbGen_SelectQueued]
(
	@TopRows INT,
	@MachineName VARCHAR(255)
)
AS
BEGIN

		SET NOCOUNT ON;

		;WITH CTE_ThumbGen AS
		(
			SELECT TOP(@TopRows)
					ID
			FROM 
					IQService_ThumbGen
			WHERE	
					[Status]='QUEUED'
			ORDER BY 
					LastModified DESC
		)

		UPDATE IQService_ThumbGen
		SET
				[Status]='SELECT',
				[MachineName]=@MachineName
		FROM
				IQService_ThumbGen
					INNER JOIN CTE_ThumbGen
						ON		IQService_ThumbGen.ID=CTE_ThumbGen.ID
							AND	IQService_ThumbGen.[Status]='QUEUED'

		SELECT 
				ID,
				ClipGuid,
				Offset
		FROM
				IQService_ThumbGen
		WHERE
				[Status]='SELECT'
			AND	[MachineName]=@MachineName

END