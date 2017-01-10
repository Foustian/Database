CREATE PROCEDURE [dbo].[usp_v4_fliQ_Application_Insert]
	@Application varchar(155),
	@Version	varchar(20),
	@Path	varchar(512),
	@Description	varchar(512),
	@IsActive	bit,
	@ApplicationID bigint output
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
		[Application] = @Application 

	IF @ApplicationCount=0
	BEGIN
		INSERT INTO fliQ_Application
		(
			[Application],
			[Version],
			[Path],
			[Description],
			DateCreated,
			DateModified,
			IsActive
		)
		Values
		(
			@Application,
			@Version,
			@Path,
			@Description,
			GETDATE(),
			GETDATE(),
			@IsActive
		)

		SET @ApplicationID = SCOPE_IDENTITY()
	END
	ELSE
	BEGIN
		SET @ApplicationID = 0
	END


END