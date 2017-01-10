CREATE PROCEDURE [dbo].[usp_v4_IQTimeshift_SavedSearch_Update]
	@Title	varchar(max),
	@SavedSearchID bigint,
	@SearchTerm xml,
	@CustomerGuid uniqueidentifier,
	@RowUpdated  int output
AS
BEGIN
	IF(Not Exists(Select Title from IQTimeshift_SavedSearch Where ID != @SavedSearchID AND Title = @Title AND CustomerGuid = @CustomerGuid  AND IsActive = 1))
	BEGIN
		IF(Not Exists(Select Title from IQTimeshift_SavedSearch Where  ID != @SavedSearchID AND convert(varchar(max),SearchTerm) = convert(varchar(max),@SearchTerm) AND CustomerGuid = @CustomerGUID  AND IsActive = 1))
		BEGIN
			UPDATE
					IQTimeshift_SavedSearch
			SET
					Title = @Title,
					SearchTerm = @SearchTerm,
					ModifiedDate = GETDATE()
			WHERE
					ID = @SavedSearchID AND CustomerGuid = @CustomerGuid

			SET @RowUpdated = @@ROWCOUNT
		END
		ELSE
		BEGIN
			SET @RowUpdated = -3
		END
	END
	ELSE
	BEGIN
		SET @RowUpdated = -2
	END

	return @RowUpdated
END