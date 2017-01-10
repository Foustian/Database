-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_v4_IQDiscovery_SavedSearch_Insert]
	@Title	varchar(max),
	@SearchTerm varchar(max),
	@SearchID varchar(max),
	@Medium varchar(20),
	@AdvanceSearchSettings xml,
	@AdvanceSearchSettingIDs varchar(max),
	--@SearchDate varchar(50),
	/*@FromDate Date,
	@ToDate Date,
	@TVMarket	varchar(255),*/
	@ClientGUID	uniqueidentifier,
	@CustomerGUID uniqueidentifier,
	@SavedSearchID bigint output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	/*if(@SearchDate = '')
		BEGIN
			SET @SearchDate = NULL
		END*/
IF(Not Exists(Select Title from IQDiscovery_SavedSearch Where Title = @Title AND CustomerGuid = @CustomerGUID  AND IsActive = 1))
	BEGIN
		   INSERT INTO IQDiscovery_SavedSearch
		   (
			   Title,
			   SearchTerm,
			   AdvanceSearchSettings,
			   Medium,
			   CustomerGUID,
			   ClientGUID,
			   DateCreated,
			   DateModified,
			   IsActive,
			   SearchID,
			   AdvanceSearchSettingIDs
		   )
		   VALUES
		   (
			   @Title,
			   cast(@SearchTerm as xml),	
			   @AdvanceSearchSettings,	
			   @Medium,	  
			   @CustomerGUID,
			   @ClientGUID,
			   GetDate(),
			   GetDate(),
			   1,
			   CAST(@SearchID as xml),
			   @AdvanceSearchSettingIDs
		   )

		   
		   SET @SavedSearchID = Scope_Identity()
	END
ELSE
	BEGIN
	 SET @SavedSearchID = -2
	END


   
END
