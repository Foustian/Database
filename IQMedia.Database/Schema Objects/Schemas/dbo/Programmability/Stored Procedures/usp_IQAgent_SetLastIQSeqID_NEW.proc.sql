CREATE PROCEDURE [dbo].[usp_IQAgent_SetLastIQSeqID_NEW]
	@SearchRequestID bigint,
	@MediaType varchar(2),
	@LastIQSeqID bigint
AS
BEGIN
	DECLARE @ID bigint
	DECLARE @CurrentLastIQSeqID bigint

	SELECT @ID = [ID], @CurrentLastIQSeqID = [LastIQSeqID]
	FROM [IQMediaGroup].[dbo].[IQAgent_LastIQSeqID_NEW] with (nolock)
	WHERE _SearchRequestID = @SearchRequestID AND MediaType = @MediaType

	IF @ID IS NULL
	BEGIN
		INSERT INTO [IQMediaGroup].[dbo].[IQAgent_LastIQSeqID_NEW]
		(_SearchRequestID,MediaType,LastIQSeqID,CreatedDate,ModifiedDate,IsActive)
		Values(@SearchRequestID,@MediaType,@LastIQSeqID,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,1)
	END
	ELSE IF @LastIQSeqID > @CurrentLastIQSeqID
	BEGIN
		UPDATE [IQMediaGroup].[dbo].[IQAgent_LastIQSeqID_NEW] with (ROWLOCK) 
		SET [LastIQSeqID] = @LastIQSeqID, [ModifiedDate] = CURRENT_TIMESTAMP
		WHERE [_SearchRequestID] = @SearchRequestID AND [ID] = @ID
	END
END