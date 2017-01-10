
CREATE PROCEDURE [dbo].[usp_Iq_Service_log_Insert]
(
	@Iq_Service_logKey	BIGINT Output,
	@ModuleName	VARCHAR(50),
	@CreatedDatetime	DATETIME,
	@ServiceCode	VARCHAR(150),
	@ConfigRequest	XML
)
AS
BEGIN

	SET NOCOUNT ON;

	INSERT INTO Iq_Service_log
	 (
		 ModuleName,
		 CreatedDatetime,
		 ServiceCode,
		 ConfigRequest
	 )
	values
	(
		@ModuleName,
		@CreatedDatetime,
		@ServiceCode,
		@ConfigRequest
	)
	
	set @Iq_Service_logKey = Scope_Identity()
	
END

