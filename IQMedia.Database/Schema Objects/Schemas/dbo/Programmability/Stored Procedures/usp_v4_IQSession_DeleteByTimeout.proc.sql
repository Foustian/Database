CREATE PROCEDURE [dbo].[usp_v4_IQSession_DeleteByTimeout]
AS
BEGIN

	DELETE
	FROM
			IQSession
	WHERE
			SYSDATETIME() > SessionTimeOut

END
