CREATE PROCEDURE [dbo].[usp_IOSService_Customer_CheckApplicationAuthentication]
	@ClientGuid uniqueidentifier,
	@Application varchar(max)
AS
BEGIN 
	DECLARE @IsAuthenticated bit =0;

	SELECT
		@IsAuthenticated  = 1 
	FROM 
		IOSService_ApplicationAuthentication
	Where
		ClientGuid  = @ClientGuid
		and [Application] = @Application
		

	SELECT @IsAuthenticated as IsAuthenticated

END