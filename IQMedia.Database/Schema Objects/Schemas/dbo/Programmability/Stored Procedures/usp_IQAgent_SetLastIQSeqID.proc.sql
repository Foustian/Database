CREATE PROCEDURE [dbo].[usp_IQAgent_SetLastIQSeqID]
	@SearchRequestID bigint,
	@MediaType varchar(2),
	@LastIQSeqID bigint
AS
BEGIN

DECLARE @ID bigint 

SELECT @ID = [ID]
FROM [IQMediaGroup].[dbo].[IQAgent_LastIQSeqID] with (nolock)
WHERE _SearchRequestID = @SearchRequestID AND MediaType = @MediaType

IF @ID IS NOT NULL
BEGIN
	UPDATE [IQMediaGroup].[dbo].[IQAgent_LastIQSeqID] with (ROWLOCK) 
	SET [LastIQSeqID] = @LastIQSeqID, [ModifiedDate] = CURRENT_TIMESTAMP
	WHERE [_SearchRequestID] = @SearchRequestID AND [ID] = @ID
END
ELSE
BEGIN
	INSERT INTO [IQMediaGroup].[dbo].[IQAgent_LastIQSeqID]
	(_SearchRequestID,MediaType,LastIQSeqID,CreatedDate,ModifiedDate,IsActive)
	Values(@SearchRequestID,@MediaType,@LastIQSeqID,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,1)
END

END