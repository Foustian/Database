CREATE PROCEDURE [dbo].[usp_ArchiveNM_InsertList]
	@XmlData			xml,
	@Status				tinyint output,
	@RowCount			int output
AS
BEGIN
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

		INSERT INTO 
				IQCore_NM
				(
					ArticleID,
					Url,
					harvest_time,
					[Status],
					_RootPathID
				)
		SELECT 
					tblXml.c.value('@ArticleID','varchar(50)') as ArticleID,
					tblXml.c.value('@ArticleUrl','varchar(255)') as ArticleUrl,
					tblXml.c.value('@Harvest_Time','datetime') as Harvest_Time,
					'QUEUED',
					@rpID
		FROM		
				@XmlData.nodes('/list/Element') as tblXml(c)
					left outer join IQCore_NM	
						ON IQCore_NM.ArticleID=tblXml.c.value('@ArticleID','varchar(50)')
		WHERE
				IQCore_NM.ArticleID is null

		INSERT INTO 
				ArchiveNM
				(
					Title,
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
					IsActive,
					CreatedDate,
					ModifiedDate,
					CompeteURL,
					harvest_time,
					Publication
				)

		SELECT 
					tblXml.c.value('@Title','varchar(250)') as Title,
					Customer.FirstName as [FirstName],
					Customer.LastName as [LastName],
					tblXml.c.value('@CustomerGuid','uniqueidentifier') as CustomerGuid,
					tblXml.c.value('@ClientGuid','uniqueidentifier') as ClientGuid,
					tblXml.c.value('@CategoryGuid','uniqueidentifier') as CategoryGuid,
					tblXml.c.value('@SubCategory1Guid','uniqueidentifier') as SubCategory1Guid,
					tblXml.c.value('@SubCategory2Guid','uniqueidentifier') as SubCategory2Guid,
					tblXml.c.value('@SubCategory3Guid','uniqueidentifier') as SubCategory3Guid,
					tblXml.c.value('@ArticleID','varchar(50)') as ArticleID,
					tblXml.c.value('@Content','varchar(max)') as ArticleContent,
					tblXml.c.value('@ArticleUrl','varchar(255)') as ArticleUrl,
					ISNULL(tblXml.c.value('@IsActive','bit'),1) as [IsActive],
					ISNULL(tblXml.c.value('@CreatedDate','datetime'),GETDATE()) as [CreatedDate],
					ISNULL(tblXml.c.value('@ModifiedDate','datetime'),GETDATE()) as [ModifiedDate],
					tblXml.c.value('@CompeteURL','varchar(255)') as CompeteURL,
					tblXml.c.value('@Harvest_Time','datetime') as Harvest_Time,
					tblXml.c.value('@Publication','varchar(255)') as docurl
		FROM		
				@XmlData.nodes('/list/Element') as tblXml(c)
					left outer join ArchiveNM
						on ArchiveNM.ArticleID=tblXml.c.value('@ArticleID','varchar(50)')
						AND ArchiveNM.IsActive = 1 AND ArchiveNM.CustomerGuid = tblXml.c.value('@CustomerGuid','uniqueidentifier')
					inner join Customer
						on tblXml.c.value('@CustomerGuid','uniqueidentifier')=Customer.CustomerGUID
		WHERE
				ArchiveNM.ArticleID is null 
		
		SET @RowCount = @@ROWCOUNT;
		SET @Status = 0

		COMMIT TRANSACTION
				
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		
		SET @Status = -1
		SET @RowCount = 0

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
				@CreatedBy='usp_ArchiveNM_InsertList',
				@ModifiedBy='usp_ArchiveNM_InsertList',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
		
		EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@ModifiedBy,@CreatedDate,@ModifiedDate,@IsActive,@IQMediaGroupExceptionKey output
		
	END CATCH
END