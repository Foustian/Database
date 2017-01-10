-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_ArchiveNM_Insert]
	@Title				varchar(250),
	@Keywords 			varchar(500),
	@Description 		varchar(1000),
	@CustomerGuid		uniqueidentifier,
	@ClientGuid			uniqueidentifier,
	@CategoryGuid		uniqueidentifier,
	@SubCategory1Guid	uniqueidentifier,
	@SubCategory2Guid	uniqueidentifier,
	@SubCategory3Guid	uniqueidentifier,
	@ArticleID			varchar(50),
	@Content			varchar(MAX),
	@ArticleUri			varchar(MAX),
	@Harvest_Time		datetime,
	@Rating				tinyint,
	@ArchiveNMKey		bigint output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	BEGIN TRANSACTION
	BEGIN TRY
		
		declare @rpID int
		Select
				@rpID=IQCore_RootPath.ID
		From
				IQCore_RootPath
					inner join IQCore_RootPathType
						on IQCore_RootPath._RootPathTypeID=IQCore_RootPathType.ID
		Where
				IQCore_RootPathType.Name='NM'
		Order by
				NEWID()
	
		IF NOT EXISTS(SELECT ArticleID FROM IQCore_Nm Where ArticleID = @ArticleID)
		BEGIN
			INSERT INTO 
				IQCore_Nm
				(
					ArticleID,
					Url,
					harvest_time,
					[Status],
					_RootPathID
				)
			VALUES
				(
					@ArticleID,
					@ArticleUri,
					@Harvest_Time,
					'QUEUED',
					@rpID
				)	
		END
		
		
		IF NOT EXISTS(SELECT ArticleID FROM ArchiveNM Where ArticleID = @ArticleID and CustomerGuid = @CustomerGuid AND IsActive=1)
		BEGIN
			INSERT INTO 
				ArchiveNM
				(
					Title,
					Keywords,
					[Description],
					FirstName,
					LastName,
					CustomerGuid,
					ClientGuid,
					CategoryGuid,
					SubCategory1Guid,
					SubCategory2Guid,
					SubCategory3Guid,
					ArticleID,
					ArticleContent,
					Url,
					Rating,
					IsActive,
					CreatedDate,
					ModifiedDate
				)
			SELECT  
					@Title,
					@Keywords,
					@Description,
					Customer.FirstName,
					Customer.LastName,
					@CustomerGuid,
					@ClientGuid,
					@CategoryGuid,
					@SubCategory1Guid,
					@SubCategory2Guid,
					@SubCategory3Guid,
					@ArticleID,
					@Content,
					@ArticleUri,
					@Rating,
					1,
					GETDATE(),
					GETDATE()
			FROM  Customer Where CustomerGuid = @CustomerGuid
			SELECT @ArchiveNMKey = SCOPE_IDENTITY()
			
			COMMIT TRANSACTION
			
		END
		ELSE
		BEGIN
			ROLLBACK TRANSACTION
			SELECT  @ArchiveNMKey = -1
		END
		
		
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		
		DECLARE @IQMediaGroupExceptionKey bigint,
				@ExceptionStackTrace varchar(500),
				@ExceptionMessage varchar(500),
				@CreatedBy	varchar(50),
				@ModifiedBy	varchar(50),
				@CreatedDate	datetime,
				@ModifiedDate	datetime,
				@IsActive	bit
				
		
		SELECT 
				@ExceptionStackTrace=(ERROR_PROCEDURE()+'_'+CONVERT(varchar(50),ERROR_LINE())),
				@ExceptionMessage=convert(varchar(50),ERROR_NUMBER())+'_'+ERROR_MESSAGE(),
				@CreatedBy='usp_ArchiveNM_Insert',
				@ModifiedBy='usp_ArchiveNM_Insert',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
				
		SET @ArchiveNMKey = 0
		
		EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@ModifiedBy,@CreatedDate,@ModifiedDate,@IsActive,@IQMediaGroupExceptionKey output
		
	END CATCH

    
END
