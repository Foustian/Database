USE [IQMediaGroup]
GO
/****** Object:  StoredProcedure [dbo].[usp_v4_IQTimeshift_SavedSearch_Insert]    Script Date: 12/9/2016 2:44:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_v4_IQTimeshift_SavedSearch_Insert]
	@Title	varchar(max),
	@SearchTerm xml,
	@ClientGuid	uniqueidentifier,
	@CustomerGuid uniqueidentifier,
	@ComponentType varchar(5),
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
IF(Not Exists(Select Title from IQTimeshift_SavedSearch Where Title = @Title AND CustomerGuid = @CustomerGuid  AND IsActive = 1))
	BEGIN
			IF(Not Exists(Select Title from IQTimeshift_SavedSearch Where convert(varchar(max),SearchTerm) = convert(varchar(max),@SearchTerm) AND CustomerGuid = @CustomerGUID  AND IsActive = 1))
			BEGIN
				INSERT INTO IQTimeshift_SavedSearch
				(
				   Title,
				   SearchTerm,
				   CustomerGuid,
				   ClientGuid,
				   CreatedDate,
				   ModifiedDate,
				   IsActive,
				   Component
			    )
			    VALUES
			    (
				   @Title,
				   cast(@SearchTerm as xml),			  
				   @CustomerGuid,
				   @ClientGuid,
				   GetDate(),
				   GetDate(),
				   1,
				   @ComponentType
			    )

			   SET @SavedSearchID = Scope_Identity()
			END
			ELSE
			BEGIN
				SET @SavedSearchID = -3
			END
	END
ELSE
	BEGIN
	 SET @SavedSearchID = -2
	END   
END