CREATE PROCEDURE [dbo].[usp_v4_fliQ_Application_Update]
	@Application varchar(155),
	@Version	varchar(20),
	@Path	varchar(512),
	@Description	varchar(512),
	@IsActive	bit,
	@ApplicationID bigint,
	@Status int output
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @ApplicationCount INT
    -- Insert statements for procedure here
    SELECT
		@ApplicationCount = COUNT(*)
	FROM
		fliQ_Application
	WHERE
		[Application] = @Application  AND ID != @ApplicationID


	IF @ApplicationCount=0
	BEGIN

		UPDATE 
				fliQ_Application
		SET
				[Application] = @Application,
				[Version] = @Version,
				[Path] = @Path,
				[Description] = @Description,
				IsActive = @IsActive,
				DateModified = GETDATE()
		WHERE
				ID = @ApplicationID
			

		SET @Status = @@ROWCOUNT
	END
	ELSE
	BEGIN
		SET @Status = 0
	END
END
