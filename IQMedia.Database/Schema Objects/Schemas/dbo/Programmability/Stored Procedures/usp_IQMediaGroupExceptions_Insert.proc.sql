-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_IQMediaGroupExceptions_Insert] 
	-- Add the parameters for the stored procedure here
	@ExceptionStackTrace varchar(500),
	@ExceptionMessage varchar(500),
	@CreatedBy varchar(50),
	@CreatedDate datetime,
	@CustomerGuid uniqueidentifier,
	@IQMediaGroupExceptionKey bigint out
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    INSERT INTO 
		IQMediaGroupException
			   (
				ExceptionStackTrace,
				ExceptionMessage,
				CustomerGuid,
				CreatedBy,
				CreatedDate
			   )
	values
			(
				@ExceptionStackTrace,
				@ExceptionMessage,
				@CustomerGuid,
				@CreatedBy,
				SYSDATETIME()
			)
	SELECT @IQMediaGroupExceptionKey = SCOPE_IDENTITY()
    
END
