CREATE PROCEDURE [dbo].[usp_v4_IQDiscovery_SavedSearch_Update]
	@SavedSearchID  bigint,
	@SearchTerm varchar(max),
	@SearchID varchar(max),
	@Medium varchar(20),
	@AdvanceSearchSettings xml,
	@AdvanceSearchSettingIDs varchar(max),
	@CustomerGUID uniqueidentifier
AS
BEGIN
	UPDATE 
			IQDiscovery_SavedSearch
	SET
			SearchTerm = @SearchTerm,
			AdvanceSearchSettings = @AdvanceSearchSettings,
			AdvanceSearchSettingIDs = @AdvanceSearchSettingIDs,
			Medium = @Medium,
			DateModified = GETDATE(),
			SearchID = @SearchID
	WHERE
			ID = @SavedSearchID AND CustomerGUID = @CustomerGUID
END