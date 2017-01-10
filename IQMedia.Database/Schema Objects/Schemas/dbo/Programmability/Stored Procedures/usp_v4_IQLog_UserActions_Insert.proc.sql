CREATE PROCEDURE [dbo].[usp_v4_IQLog_UserActions_Insert]
	@SessionID varchar(50),
	@CustomerID bigint,
	@ActionName varchar(100),
	@PageName varchar(50),
	@RequestParameters varchar(max),
	@RequestDateTime datetime,
	@IPAddress varchar(20)
AS
BEGIN
	
	SET NOCOUNT ON;
	
	INSERT INTO IQLog_UserActions
	(
		SessionID,
		CustomerID,
		ActionName,
		PageName,
		RequestParameters,
		RequestDateTime,
		IPAddress
	)
	Values
	(
		@SessionID,
		@CustomerID,
		@ActionName,
		@PageName,
		@RequestParameters,
		@RequestDateTime,
		@IPAddress
	)
	
	SELECT SCOPE_IDENTITY();
END