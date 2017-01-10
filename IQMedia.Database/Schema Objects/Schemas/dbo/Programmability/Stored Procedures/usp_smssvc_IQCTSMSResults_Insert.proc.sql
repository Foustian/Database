CREATE PROCEDURE [dbo].[usp_smssvc_IQCTSMSResults_Insert]
	@CustomerPhoneNo varchar(11),
	@ReceivedDateTime	datetime,
	@MsgText	datetime,
	@MessageID	varchar(50)
AS
BEGIN
		
		DECLARE @IQCTSMSResultsKey bigint = 0
		
		INSERT INTO IQCTSMSResults
		(
			CustomerPhoneNo,
			ReceivedDateTime,
			MsgText,
			MessageID,
			CreatedDate,
			ModifiedDate
		)
		VALUES
		(
			@CustomerPhoneNo,
			@ReceivedDateTime,
			@MsgText,
			@MessageID,
			GETDATE(),
			GETDATE()
		)

		SET @IQCTSMSResultsKey =  SCOPE_IDENTITY()

		SELECT @IQCTSMSResultsKey as IQCTSMSResultsKey
END