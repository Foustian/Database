-- =============================================
-- Author:		<Author,,Name>
-- Create date: 29 July 2013
-- Description:	Filter functionality for IQUGCArvhive
-- =============================================
CREATE PROCEDURE [dbo].[usp_v4_IQUGCArchive_SelectFilter]
	@FromDate			DATE,
	@ToDate				DATE,
	@SearchTerm			VARCHAR(4000),
	@CategoryGUID		xml,
	@CustomerGUID		UNIQUEIDENTIFIER,
	@ClientGuid			UNIQUEIDENTIFIER,
	@SelectionType		varchar(3),
	@FileType			varchar(20),
	@SinceID			BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @TotalCats  int 					
	DECLARE @TempTable table(CategoryGuid uniqueidentifier)

	IF(@SearchTerm IS NULL)
	BEGIN
		IF(@CategoryGUID IS NULL)
		BEGIN
			-- CreatedDT Count
	
			SELECT	
						DISTINCT CAST(IQUGCArchive.DateUploaded AS DATE) AS DateUploaded
			FROM	IQUGCArchive	
						INNER JOIN IQUGC_FileTypes
										ON IQUGCArchive._FileTypeID  = IQUGC_FileTypes.ID
										AND IQUGC_FileTypes.IsActive = 1
			WHERE	IQUGCArchive.ClientGUID = @ClientGUID
			AND		IQUGCArchive.IsActive = 1
			AND		(@CustomerGUID IS NULL OR IQUGCArchive.CustomerGUID = @CustomerGUID)
			AND		((@FromDate is null or @ToDate is null) OR CAST(IQUGCArchive.DateUploaded AS DATE) BETWEEN @FromDate AND @ToDate) 
			AND		(@FileType IS NULL OR IQUGC_FileTypes.Filetype = @FileType)
			AND		((@SinceID IS NULL OR @SinceID = 0) OR IQUGCArchiveKey <= @SinceID )

			-- Category Count

			SELECT	
						CustomCategory.CategoryGUID,
						CategoryName,
						COUNT(IQUGCArchiveKey) AS CategoryCount
			FROM	IQUGCArchive
						INNER JOIN IQUGC_FileTypes
										ON IQUGCArchive._FileTypeID  = IQUGC_FileTypes.ID
										AND IQUGC_FileTypes.IsActive = 1
			INNER JOIN CustomCategory
					ON	
						(
							CustomCategory.CategoryGUID = IQUGCArchive.CategoryGUID
							OR CustomCategory.CategoryGUID = IQUGCArchive.SubCategory1GUID
							OR CustomCategory.CategoryGUID = IQUGCArchive.SubCategory2GUID
							OR CustomCategory.CategoryGUID = IQUGCArchive.SubCategory3GUID
						)
					AND		CustomCategory.ClientGUID = @ClientGuid
	
			WHERE	IQUGCArchive.ClientGUID = @ClientGUID
			AND		IQUGCArchive.IsActive = 1
			AND		CustomCategory.IsActive = 1
			AND		(@CustomerGUID IS NULL OR IQUGCArchive.CustomerGUID = @CustomerGUID)
			AND		((@FromDate is null or @ToDate is null) OR CAST(IQUGCArchive.DateUploaded AS DATE) BETWEEN @FromDate AND @ToDate) 
			AND		(@FileType IS NULL OR IQUGC_FileTypes.Filetype = @FileType)
			AND		((@SinceID IS NULL OR @SinceID = 0) OR IQUGCArchiveKey <= @SinceID )
	
			GROUP BY CustomCategory.CategoryGUID,CategoryName
	
	
			-- Customer Count
	
			SELECT	
						IQUGCArchive.CustomerGUID,
						Customer.FirstName + ' ' + Customer.LastName AS CustomerName,
						COUNT(IQUGCArchivekeY) AS CustomerCount
					
			FROM	IQUGCArchive
			INNER JOIN Customer
			ON Customer.CustomerGUID = IQUGCArchive.CustomerGUID
					INNER JOIN IQUGC_FileTypes
										ON IQUGCArchive._FileTypeID  = IQUGC_FileTypes.ID
										AND IQUGC_FileTypes.IsActive = 1
	
			WHERE	IQUGCArchive.ClientGUID = @ClientGUID
			AND		IQUGCArchive.IsActive = 1
			AND		(@CustomerGUID IS NULL OR IQUGCArchive.CustomerGUID = @CustomerGUID)
			AND		((@FromDate is null or @ToDate is null) OR CAST(IQUGCArchive.DateUploaded AS DATE) BETWEEN @FromDate AND @ToDate) 
			AND		(@FileType IS NULL OR IQUGC_FileTypes.Filetype = @FileType)
			AND		((@SinceID IS NULL OR @SinceID = 0) OR IQUGCArchiveKey <= @SinceID )
	
			GROUP BY IQUGCArchive.CustomerGUID,Customer.FirstName + ' ' + Customer.LastName


			-- FileType Count
			SELECT	
						IQUGC_FileTypes.FileType,
						COUNT(IQUGCArchivekeY) AS FileTypeCount
					
			FROM	IQUGCArchive
					INNER JOIN IQUGC_FileTypes
										ON IQUGCArchive._FileTypeID  = IQUGC_FileTypes.ID
										AND IQUGC_FileTypes.IsActive = 1
	
			WHERE	IQUGCArchive.ClientGUID = @ClientGUID
			AND		IQUGCArchive.IsActive = 1
			AND		(@CustomerGUID IS NULL OR IQUGCArchive.CustomerGUID = @CustomerGUID)
			AND		((@FromDate is null or @ToDate is null) OR CAST(IQUGCArchive.DateUploaded AS DATE) BETWEEN @FromDate AND @ToDate) 
			AND		(@FileType IS NULL OR IQUGC_FileTypes.Filetype = @FileType)
			AND		((@SinceID IS NULL OR @SinceID = 0) OR IQUGCArchiveKey <= @SinceID )	
			GROUP BY IQUGC_FileTypes.FileType
		END
		ELSE
		BEGIN

				INSERT INTO @TempTable
				SELECT cat.item.value('@guid','uniqueidentifier') FROM @CategoryGUID.nodes('list/item') as cat(item)

				SELECT @TotalCats = count(*) FROM @TempTable as t

				IF(UPPER(@SelectionType) = 'AND')
				BEGIN
					-- CreatedDT Count
	
					SELECT	
								DISTINCT CAST(IQUGCArchive.DateUploaded AS DATE) AS DateUploaded
					FROM	IQUGCArchive
								INNER JOIN IQUGC_FileTypes
										ON IQUGCArchive._FileTypeID  = IQUGC_FileTypes.ID
										AND IQUGC_FileTypes.IsActive = 1
					WHERE		(
								IQUGCArchive.CategoryGUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
								OR IQUGCArchive.SubCategory1GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
								OR IQUGCArchive.SubCategory2GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
								OR IQUGCArchive.SubCategory3GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
							)
					AND		IQUGCArchive.ClientGUID = @ClientGUID
					AND		IQUGCArchive.IsActive = 1
					AND		(@CustomerGUID IS NULL OR IQUGCArchive.CustomerGUID = @CustomerGUID)
					AND		((@FromDate is null or @ToDate is null) OR CAST(IQUGCArchive.DateUploaded AS DATE) BETWEEN @FromDate AND @ToDate) 
					AND		(@FileType IS NULL OR IQUGC_FileTypes.Filetype = @FileType)
					AND (CASE WHEN  IQUGCArchive.CategoryGUID in (SELECT t1.CategoryGUID FROM @TempTable t1) THEN
							1
					ELSE
							0
					END + 
					CASE WHEN  IQUGCArchive.SubCategory1GUID in (SELECT t1.CategoryGUID FROM @TempTable t1) THEN
							1
					ELSE
							0
					END +
					CASE WHEN  IQUGCArchive.SubCategory2GUID in (SELECT t1.CategoryGUID FROM @TempTable t1) THEN
							1
					ELSE
							0
					END +
					CASE WHEN  IQUGCArchive.SubCategory3GUID in (SELECT t1.CategoryGUID FROM @TempTable t1) THEN
							1
					ELSE
							0 
					END) >= CASE WHEN @TotalCats < 4 THEN @TotalCats ELSE 4 END

					-- Category Count

					SELECT	
								CustomCategory.CategoryGUID,
								CategoryName,
								COUNT(IQUGCArchiveKey) AS CategoryCount
					FROM	IQUGCArchive
								INNER JOIN IQUGC_FileTypes
										ON IQUGCArchive._FileTypeID  = IQUGC_FileTypes.ID
										AND IQUGC_FileTypes.IsActive = 1
	
					INNER JOIN CustomCategory
					ON		CustomCategory.ClientGUID = @ClientGuid
					AND	(
							CustomCategory.CategoryGUID = IQUGCArchive.CategoryGUID
							OR CustomCategory.CategoryGUID = IQUGCArchive.SubCategory1GUID
							OR CustomCategory.CategoryGUID = IQUGCArchive.SubCategory2GUID
							OR CustomCategory.CategoryGUID = IQUGCArchive.SubCategory3GUID
						)
	
					WHERE		(
								IQUGCArchive.CategoryGUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
								OR IQUGCArchive.SubCategory1GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
								OR IQUGCArchive.SubCategory2GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
								OR IQUGCArchive.SubCategory3GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
							)
					AND		IQUGCArchive.ClientGUID = @ClientGUID
					AND		IQUGCArchive.IsActive = 1
					AND		CustomCategory.IsActive = 1
					AND		(@CustomerGUID IS NULL OR IQUGCArchive.CustomerGUID = @CustomerGUID)
					AND		((@FromDate is null or @ToDate is null) OR CAST(IQUGCArchive.DateUploaded AS DATE) BETWEEN @FromDate AND @ToDate) 
					AND		((@SinceID IS NULL OR @SinceID = 0) OR IQUGCArchiveKey <= @SinceID )
					AND		(@FileType IS NULL OR IQUGC_FileTypes.Filetype = @FileType)
					AND (CASE WHEN  IQUGCArchive.CategoryGUID in (SELECT t1.CategoryGUID FROM @TempTable t1) THEN
							1
					ELSE
							0
					END + 
					CASE WHEN  IQUGCArchive.SubCategory1GUID in (SELECT t1.CategoryGUID FROM @TempTable t1) THEN
							1
					ELSE
							0
					END +
					CASE WHEN  IQUGCArchive.SubCategory2GUID in (SELECT t1.CategoryGUID FROM @TempTable t1) THEN
							1
					ELSE
							0
					END +
					CASE WHEN  IQUGCArchive.SubCategory3GUID in (SELECT t1.CategoryGUID FROM @TempTable t1) THEN
							1
					ELSE
							0 
					END) >= CASE WHEN @TotalCats < 4 THEN @TotalCats ELSE 4 END
	
					GROUP BY CustomCategory.CategoryGUID,CategoryName
	
	
					-- Customer Count
	
					SELECT	
								IQUGCArchive.CustomerGUID,
								Customer.FirstName + ' ' + Customer.LastName AS CustomerName,
								COUNT(IQUGCArchivekeY) AS CustomerCount
					
					FROM	IQUGCArchive
								INNER JOIN IQUGC_FileTypes
										ON IQUGCArchive._FileTypeID  = IQUGC_FileTypes.ID
										AND IQUGC_FileTypes.IsActive = 1
					INNER JOIN Customer
					ON Customer.CustomerGUID = IQUGCArchive.CustomerGUID
	
					WHERE		(
								IQUGCArchive.CategoryGUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
								OR IQUGCArchive.SubCategory1GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
								OR IQUGCArchive.SubCategory2GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
								OR IQUGCArchive.SubCategory3GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
							)
					AND		IQUGCArchive.ClientGUID = @ClientGUID
					AND		IQUGCArchive.IsActive = 1
					AND		(@CustomerGUID IS NULL OR IQUGCArchive.CustomerGUID = @CustomerGUID)
					AND		((@FromDate is null or @ToDate is null) OR CAST(IQUGCArchive.DateUploaded AS DATE) BETWEEN @FromDate AND @ToDate) 
					AND		(@FileType IS NULL OR IQUGC_FileTypes.Filetype = @FileType)
					AND		((@SinceID IS NULL OR @SinceID = 0) OR IQUGCArchiveKey <= @SinceID )
					AND (CASE WHEN  IQUGCArchive.CategoryGUID in (SELECT t1.CategoryGUID FROM @TempTable t1) THEN
							1
					ELSE
							0
					END + 
					CASE WHEN  IQUGCArchive.SubCategory1GUID in (SELECT t1.CategoryGUID FROM @TempTable t1) THEN
							1
					ELSE
							0
					END +
					CASE WHEN  IQUGCArchive.SubCategory2GUID in (SELECT t1.CategoryGUID FROM @TempTable t1) THEN
							1
					ELSE
							0
					END +
					CASE WHEN  IQUGCArchive.SubCategory3GUID in (SELECT t1.CategoryGUID FROM @TempTable t1) THEN
							1
					ELSE
							0 
					END) >= CASE WHEN @TotalCats < 4 THEN @TotalCats ELSE 4 END
					GROUP BY IQUGCArchive.CustomerGUID,Customer.FirstName + ' ' + Customer.LastName

					-- FileType Count
					SELECT	
								IQUGC_FileTypes.FileType,
								COUNT(IQUGCArchivekeY) AS FileTypeCount
					
					FROM	IQUGCArchive
							INNER JOIN IQUGC_FileTypes
												ON IQUGCArchive._FileTypeID  = IQUGC_FileTypes.ID
												AND IQUGC_FileTypes.IsActive = 1
	
					WHERE		(
								IQUGCArchive.CategoryGUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
								OR IQUGCArchive.SubCategory1GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
								OR IQUGCArchive.SubCategory2GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
								OR IQUGCArchive.SubCategory3GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
							)
							AND		IQUGCArchive.ClientGUID = @ClientGUID
							AND		IQUGCArchive.IsActive = 1
							AND		(@CustomerGUID IS NULL OR IQUGCArchive.CustomerGUID = @CustomerGUID)
							AND		((@FromDate is null or @ToDate is null) OR CAST(IQUGCArchive.DateUploaded AS DATE) BETWEEN @FromDate AND @ToDate) 
							AND		(@FileType IS NULL OR IQUGC_FileTypes.Filetype = @FileType)
							AND		((@SinceID IS NULL OR @SinceID = 0) OR IQUGCArchiveKey <= @SinceID )
							AND (CASE WHEN  IQUGCArchive.CategoryGUID in (SELECT t1.CategoryGUID FROM @TempTable t1) THEN
									1
							ELSE
									0
							END + 
							CASE WHEN  IQUGCArchive.SubCategory1GUID in (SELECT t1.CategoryGUID FROM @TempTable t1) THEN
									1
							ELSE
									0
							END +
							CASE WHEN  IQUGCArchive.SubCategory2GUID in (SELECT t1.CategoryGUID FROM @TempTable t1) THEN
									1
							ELSE
									0
							END +
							CASE WHEN  IQUGCArchive.SubCategory3GUID in (SELECT t1.CategoryGUID FROM @TempTable t1) THEN
									1
							ELSE
									0 
							END) >= CASE WHEN @TotalCats < 4 THEN @TotalCats ELSE 4 END
					GROUP BY IQUGC_FileTypes.FileType

				END
				ELSE
				BEGIN
					-- CreatedDT Count
	
					SELECT	
								DISTINCT CAST(IQUGCArchive.DateUploaded AS DATE) AS DateUploaded
					FROM	IQUGCArchive
								INNER JOIN IQUGC_FileTypes
										ON IQUGCArchive._FileTypeID  = IQUGC_FileTypes.ID
										AND IQUGC_FileTypes.IsActive = 1
					WHERE	(
								IQUGCArchive.CategoryGUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
								OR IQUGCArchive.SubCategory1GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
								OR IQUGCArchive.SubCategory2GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
								OR IQUGCArchive.SubCategory3GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
							)
					AND		IQUGCArchive.ClientGUID = @ClientGUID
					AND		IQUGCArchive.IsActive = 1
					AND		(@CustomerGUID IS NULL OR IQUGCArchive.CustomerGUID = @CustomerGUID)
					AND		((@FromDate is null or @ToDate is null) OR CAST(IQUGCArchive.DateUploaded AS DATE) BETWEEN @FromDate AND @ToDate) 
					AND		(@FileType IS NULL OR IQUGC_FileTypes.Filetype = @FileType)
					AND		((@SinceID IS NULL OR @SinceID = 0) OR IQUGCArchiveKey <= @SinceID )

					-- Category Count

					SELECT	
								CustomCategory.CategoryGUID,
								CategoryName,
								COUNT(IQUGCArchiveKey) AS CategoryCount
					FROM	IQUGCArchive
								INNER JOIN IQUGC_FileTypes
										ON IQUGCArchive._FileTypeID  = IQUGC_FileTypes.ID
										AND IQUGC_FileTypes.IsActive = 1
	
					INNER JOIN CustomCategory
					ON		CustomCategory.CategoryGUID IN (SELECT t1.CategoryGUID FROM @TempTable t1)
					AND		CustomCategory.ClientGUID = @ClientGuid
					AND	(
							CustomCategory.CategoryGUID = IQUGCArchive.CategoryGUID
							OR CustomCategory.CategoryGUID = IQUGCArchive.SubCategory1GUID
							OR CustomCategory.CategoryGUID = IQUGCArchive.SubCategory2GUID
							OR CustomCategory.CategoryGUID = IQUGCArchive.SubCategory3GUID
						)
	
					WHERE		(
								IQUGCArchive.CategoryGUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
								OR IQUGCArchive.SubCategory1GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
								OR IQUGCArchive.SubCategory2GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
								OR IQUGCArchive.SubCategory3GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
							)
					AND		IQUGCArchive.ClientGUID = @ClientGUID
					AND		IQUGCArchive.IsActive = 1
					AND		CustomCategory.IsActive = 1
					AND		(@CustomerGUID IS NULL OR IQUGCArchive.CustomerGUID = @CustomerGUID)
					AND		((@FromDate is null or @ToDate is null) OR CAST(IQUGCArchive.DateUploaded AS DATE) BETWEEN @FromDate AND @ToDate) 
					AND		(@FileType IS NULL OR IQUGC_FileTypes.Filetype = @FileType)
					AND		((@SinceID IS NULL OR @SinceID = 0) OR IQUGCArchiveKey <= @SinceID )
	
					GROUP BY CustomCategory.CategoryGUID,CategoryName
	
	
					-- Customer Count
	
					SELECT	
								IQUGCArchive.CustomerGUID,
								Customer.FirstName + ' ' + Customer.LastName AS CustomerName,
								COUNT(IQUGCArchivekeY) AS CustomerCount
					
					FROM	IQUGCArchive
								INNER JOIN IQUGC_FileTypes
										ON IQUGCArchive._FileTypeID  = IQUGC_FileTypes.ID
										AND IQUGC_FileTypes.IsActive = 1
					INNER JOIN Customer
					ON Customer.CustomerGUID = IQUGCArchive.CustomerGUID
	
					WHERE		(
								IQUGCArchive.CategoryGUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
								OR IQUGCArchive.SubCategory1GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
								OR IQUGCArchive.SubCategory2GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
								OR IQUGCArchive.SubCategory3GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
							)
					AND		IQUGCArchive.ClientGUID = @ClientGUID
					AND		IQUGCArchive.IsActive = 1
					AND		(@CustomerGUID IS NULL OR IQUGCArchive.CustomerGUID = @CustomerGUID)
					AND		((@FromDate is null or @ToDate is null) OR CAST(IQUGCArchive.DateUploaded AS DATE) BETWEEN @FromDate AND @ToDate) 
					AND		(@FileType IS NULL OR IQUGC_FileTypes.Filetype = @FileType)
					AND		((@SinceID IS NULL OR @SinceID = 0) OR IQUGCArchiveKey <= @SinceID )
	
					GROUP BY IQUGCArchive.CustomerGUID,Customer.FirstName + ' ' + Customer.LastName

					-- FileType Count
					SELECT	
								IQUGC_FileTypes.FileType,
								COUNT(IQUGCArchivekeY) AS FileTypeCount
					
					FROM	IQUGCArchive
							INNER JOIN IQUGC_FileTypes
												ON IQUGCArchive._FileTypeID  = IQUGC_FileTypes.ID
												AND IQUGC_FileTypes.IsActive = 1
	
					WHERE		(
								IQUGCArchive.CategoryGUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
								OR IQUGCArchive.SubCategory1GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
								OR IQUGCArchive.SubCategory2GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
								OR IQUGCArchive.SubCategory3GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
							)
					AND		IQUGCArchive.ClientGUID = @ClientGUID
					AND		IQUGCArchive.IsActive = 1
					AND		(@CustomerGUID IS NULL OR IQUGCArchive.CustomerGUID = @CustomerGUID)
					AND		((@FromDate is null or @ToDate is null) OR CAST(IQUGCArchive.DateUploaded AS DATE) BETWEEN @FromDate AND @ToDate) 
					AND		(@FileType IS NULL OR IQUGC_FileTypes.Filetype = @FileType)
					AND		((@SinceID IS NULL OR @SinceID = 0) OR IQUGCArchiveKey <= @SinceID )
					GROUP BY IQUGC_FileTypes.FileType
				END
		END
	END
	ELSE
	BEGIN
		IF(@CategoryGUID IS NULL)
		BEGIN
			-- CreatedDT Count
	
			SELECT	
						DISTINCT CAST(IQUGCArchive.DateUploaded AS DATE) AS DateUploaded
			FROM	IQUGCArchive	
						INNER JOIN IQUGC_FileTypes
										ON IQUGCArchive._FileTypeID  = IQUGC_FileTypes.ID
										AND IQUGC_FileTypes.IsActive = 1
			WHERE	IQUGCArchive.ClientGUID = @ClientGUID
			AND		IQUGCArchive.IsActive = 1
			AND		(@CustomerGUID IS NULL OR IQUGCArchive.CustomerGUID = @CustomerGUID)
			AND		((@FromDate is null or @ToDate is null) OR CAST(IQUGCArchive.DateUploaded AS DATE) BETWEEN @FromDate AND @ToDate) 
			AND		(@FileType IS NULL OR IQUGC_FileTypes.Filetype = @FileType)
			AND		(@SearchTerm Is NULL OR Contains((Title, Keywords, [Description]), @SearchTerm)) 
			AND		((@SinceID IS NULL OR @SinceID = 0) OR IQUGCArchiveKey <= @SinceID )

			-- Category Count

			SELECT	
						CustomCategory.CategoryGUID,
						CategoryName,
						COUNT(IQUGCArchiveKey) AS CategoryCount
			FROM	IQUGCArchive
						INNER JOIN IQUGC_FileTypes
										ON IQUGCArchive._FileTypeID  = IQUGC_FileTypes.ID
										AND IQUGC_FileTypes.IsActive = 1
			INNER JOIN CustomCategory
					ON	
						(
							CustomCategory.CategoryGUID = IQUGCArchive.CategoryGUID
							OR CustomCategory.CategoryGUID = IQUGCArchive.SubCategory1GUID
							OR CustomCategory.CategoryGUID = IQUGCArchive.SubCategory2GUID
							OR CustomCategory.CategoryGUID = IQUGCArchive.SubCategory3GUID
						)
					AND		CustomCategory.ClientGUID = @ClientGuid
	
			WHERE	IQUGCArchive.ClientGUID = @ClientGUID
			AND		IQUGCArchive.IsActive = 1
			AND		CustomCategory.IsActive = 1
			AND		(@CustomerGUID IS NULL OR IQUGCArchive.CustomerGUID = @CustomerGUID)
			AND		((@FromDate is null or @ToDate is null) OR CAST(IQUGCArchive.DateUploaded AS DATE) BETWEEN @FromDate AND @ToDate)
			AND		(@FileType IS NULL OR IQUGC_FileTypes.Filetype = @FileType) 
			AND		(@SearchTerm Is NULL OR Contains((Title, Keywords, [Description]), @SearchTerm)) 
			AND		((@SinceID IS NULL OR @SinceID = 0) OR IQUGCArchiveKey <= @SinceID )
	
			GROUP BY CustomCategory.CategoryGUID,CategoryName
	
	
			-- Customer Count
	
			SELECT	
						IQUGCArchive.CustomerGUID,
						Customer.FirstName + ' ' + Customer.LastName AS CustomerName,
						COUNT(IQUGCArchivekeY) AS CustomerCount
					
			FROM	IQUGCArchive
						INNER JOIN IQUGC_FileTypes
										ON IQUGCArchive._FileTypeID  = IQUGC_FileTypes.ID
										AND IQUGC_FileTypes.IsActive = 1
			INNER JOIN Customer
			ON Customer.CustomerGUID = IQUGCArchive.CustomerGUID
	
			WHERE	IQUGCArchive.ClientGUID = @ClientGUID
			AND		IQUGCArchive.IsActive = 1
			AND		(@CustomerGUID IS NULL OR IQUGCArchive.CustomerGUID = @CustomerGUID)
			AND		((@FromDate is null or @ToDate is null) OR CAST(IQUGCArchive.DateUploaded AS DATE) BETWEEN @FromDate AND @ToDate) 
			AND		(@FileType IS NULL OR IQUGC_FileTypes.Filetype = @FileType)
			AND		(@SearchTerm Is NULL OR Contains((Title, Keywords, [Description]), @SearchTerm)) 
			AND		((@SinceID IS NULL OR @SinceID = 0) OR IQUGCArchiveKey <= @SinceID )
	
			GROUP BY IQUGCArchive.CustomerGUID,Customer.FirstName + ' ' + Customer.LastName


			-- FileType Count
			SELECT	
						IQUGC_FileTypes.FileType,
						COUNT(IQUGCArchivekeY) AS FileTypeCount
			FROM	IQUGCArchive	
						INNER JOIN IQUGC_FileTypes
										ON IQUGCArchive._FileTypeID  = IQUGC_FileTypes.ID
										AND IQUGC_FileTypes.IsActive = 1
			WHERE	IQUGCArchive.ClientGUID = @ClientGUID
			AND		IQUGCArchive.IsActive = 1
			AND		(@CustomerGUID IS NULL OR IQUGCArchive.CustomerGUID = @CustomerGUID)
			AND		((@FromDate is null or @ToDate is null) OR CAST(IQUGCArchive.DateUploaded AS DATE) BETWEEN @FromDate AND @ToDate) 
			AND		(@FileType IS NULL OR IQUGC_FileTypes.Filetype = @FileType)
			AND		(@SearchTerm Is NULL OR Contains((Title, Keywords, [Description]), @SearchTerm)) 
			AND		((@SinceID IS NULL OR @SinceID = 0) OR IQUGCArchiveKey <= @SinceID )
			group by IQUGC_FileTypes.FileType

		END
		ELSE
		BEGIN

				INSERT INTO @TempTable
				SELECT cat.item.value('@guid','uniqueidentifier') FROM @CategoryGUID.nodes('list/item') as cat(item)

				SELECT @TotalCats = count(*) FROM @TempTable as t

				IF(UPPER(@SelectionType) = 'AND')
				BEGIN
					-- CreatedDT Count
	
					SELECT	
								DISTINCT CAST(IQUGCArchive.DateUploaded AS DATE) AS DateUploaded
					FROM	IQUGCArchive
								INNER JOIN IQUGC_FileTypes
										ON IQUGCArchive._FileTypeID  = IQUGC_FileTypes.ID
										AND IQUGC_FileTypes.IsActive = 1
					WHERE		(
								IQUGCArchive.CategoryGUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
								OR IQUGCArchive.SubCategory1GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
								OR IQUGCArchive.SubCategory2GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
								OR IQUGCArchive.SubCategory3GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
							)
					AND		IQUGCArchive.ClientGUID = @ClientGUID
					AND		IQUGCArchive.IsActive = 1
					AND		(@CustomerGUID IS NULL OR IQUGCArchive.CustomerGUID = @CustomerGUID)
					AND		((@FromDate is null or @ToDate is null) OR CAST(IQUGCArchive.DateUploaded AS DATE) BETWEEN @FromDate AND @ToDate) 
					AND		(@FileType IS NULL OR IQUGC_FileTypes.Filetype = @FileType)
					AND		(@SearchTerm Is NULL OR Contains((Title, Keywords, [Description]), @SearchTerm)) 
					AND		((@SinceID IS NULL OR @SinceID = 0) OR IQUGCArchiveKey <= @SinceID )
					AND (CASE WHEN  IQUGCArchive.CategoryGUID in (SELECT t1.CategoryGUID FROM @TempTable t1) THEN
							1
					ELSE
							0
					END + 
					CASE WHEN  IQUGCArchive.SubCategory1GUID in (SELECT t1.CategoryGUID FROM @TempTable t1) THEN
							1
					ELSE
							0
					END +
					CASE WHEN  IQUGCArchive.SubCategory2GUID in (SELECT t1.CategoryGUID FROM @TempTable t1) THEN
							1
					ELSE
							0
					END +
					CASE WHEN  IQUGCArchive.SubCategory3GUID in (SELECT t1.CategoryGUID FROM @TempTable t1) THEN
							1
					ELSE
							0 
					END) >= CASE WHEN @TotalCats < 4 THEN @TotalCats ELSE 4 END

					-- Category Count

					SELECT	
								CustomCategory.CategoryGUID,
								CategoryName,
								COUNT(IQUGCArchiveKey) AS CategoryCount
					FROM	IQUGCArchive
								INNER JOIN IQUGC_FileTypes
										ON IQUGCArchive._FileTypeID  = IQUGC_FileTypes.ID
										AND IQUGC_FileTypes.IsActive = 1
	
					INNER JOIN CustomCategory
					ON		CustomCategory.ClientGUID = @ClientGuid
					AND	(
							CustomCategory.CategoryGUID = IQUGCArchive.CategoryGUID
							OR CustomCategory.CategoryGUID = IQUGCArchive.SubCategory1GUID
							OR CustomCategory.CategoryGUID = IQUGCArchive.SubCategory2GUID
							OR CustomCategory.CategoryGUID = IQUGCArchive.SubCategory3GUID
						)
	
					WHERE		(
								IQUGCArchive.CategoryGUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
								OR IQUGCArchive.SubCategory1GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
								OR IQUGCArchive.SubCategory2GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
								OR IQUGCArchive.SubCategory3GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
							)
					AND		IQUGCArchive.ClientGUID = @ClientGUID
					AND		IQUGCArchive.IsActive = 1
					AND		CustomCategory.IsActive = 1
					AND		(@CustomerGUID IS NULL OR IQUGCArchive.CustomerGUID = @CustomerGUID)
					AND		((@FromDate is null or @ToDate is null) OR CAST(IQUGCArchive.DateUploaded AS DATE) BETWEEN @FromDate AND @ToDate) 
					AND		(@FileType IS NULL OR IQUGC_FileTypes.Filetype = @FileType)
					AND		(@SearchTerm Is NULL OR Contains((Title, Keywords, [Description]), @SearchTerm)) 
					AND		((@SinceID IS NULL OR @SinceID = 0) OR IQUGCArchiveKey <= @SinceID )
					AND (CASE WHEN  IQUGCArchive.CategoryGUID in (SELECT t1.CategoryGUID FROM @TempTable t1) THEN
							1
					ELSE
							0
					END + 
					CASE WHEN  IQUGCArchive.SubCategory1GUID in (SELECT t1.CategoryGUID FROM @TempTable t1) THEN
							1
					ELSE
							0
					END +
					CASE WHEN  IQUGCArchive.SubCategory2GUID in (SELECT t1.CategoryGUID FROM @TempTable t1) THEN
							1
					ELSE
							0
					END +
					CASE WHEN  IQUGCArchive.SubCategory3GUID in (SELECT t1.CategoryGUID FROM @TempTable t1) THEN
							1
					ELSE
							0 
					END) >= CASE WHEN @TotalCats < 4 THEN @TotalCats ELSE 4 END
	
					GROUP BY CustomCategory.CategoryGUID,CategoryName
	
	
					-- Customer Count
	
					SELECT	
								IQUGCArchive.CustomerGUID,
								Customer.FirstName + ' ' + Customer.LastName AS CustomerName,
								COUNT(IQUGCArchivekeY) AS CustomerCount
					
					FROM	IQUGCArchive
								INNER JOIN IQUGC_FileTypes
										ON IQUGCArchive._FileTypeID  = IQUGC_FileTypes.ID
										AND IQUGC_FileTypes.IsActive = 1
					INNER JOIN Customer
					ON Customer.CustomerGUID = IQUGCArchive.CustomerGUID
	
					WHERE		(
								IQUGCArchive.CategoryGUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
								OR IQUGCArchive.SubCategory1GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
								OR IQUGCArchive.SubCategory2GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
								OR IQUGCArchive.SubCategory3GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
							)
					AND		IQUGCArchive.ClientGUID = @ClientGUID
					AND		IQUGCArchive.IsActive = 1
					AND		(@CustomerGUID IS NULL OR IQUGCArchive.CustomerGUID = @CustomerGUID)
					AND		((@FromDate is null or @ToDate is null) OR CAST(IQUGCArchive.DateUploaded AS DATE) BETWEEN @FromDate AND @ToDate) 
					AND		(@FileType IS NULL OR IQUGC_FileTypes.Filetype = @FileType)
					AND		(@SearchTerm Is NULL OR Contains((Title, Keywords, [Description]), @SearchTerm)) 
					AND		((@SinceID IS NULL OR @SinceID = 0) OR IQUGCArchiveKey <= @SinceID )
					AND (CASE WHEN  IQUGCArchive.CategoryGUID in (SELECT t1.CategoryGUID FROM @TempTable t1) THEN
							1
					ELSE
							0
					END + 
					CASE WHEN  IQUGCArchive.SubCategory1GUID in (SELECT t1.CategoryGUID FROM @TempTable t1) THEN
							1
					ELSE
							0
					END +
					CASE WHEN  IQUGCArchive.SubCategory2GUID in (SELECT t1.CategoryGUID FROM @TempTable t1) THEN
							1
					ELSE
							0
					END +
					CASE WHEN  IQUGCArchive.SubCategory3GUID in (SELECT t1.CategoryGUID FROM @TempTable t1) THEN
							1
					ELSE
							0 
					END) >= CASE WHEN @TotalCats < 4 THEN @TotalCats ELSE 4 END
					GROUP BY IQUGCArchive.CustomerGUID,Customer.FirstName + ' ' + Customer.LastName

					-- FileType Count
					SELECT	
								IQUGC_FileTypes.FileType,
								COUNT(IQUGCArchivekeY) AS FileTypeCount
					FROM	IQUGCArchive	
								INNER JOIN IQUGC_FileTypes
												ON IQUGCArchive._FileTypeID  = IQUGC_FileTypes.ID
												AND IQUGC_FileTypes.IsActive = 1
					WHERE		(
								IQUGCArchive.CategoryGUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
								OR IQUGCArchive.SubCategory1GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
								OR IQUGCArchive.SubCategory2GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
								OR IQUGCArchive.SubCategory3GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
							)
					AND		IQUGCArchive.ClientGUID = @ClientGUID
					AND		IQUGCArchive.IsActive = 1
					AND		(@CustomerGUID IS NULL OR IQUGCArchive.CustomerGUID = @CustomerGUID)
					AND		((@FromDate is null or @ToDate is null) OR CAST(IQUGCArchive.DateUploaded AS DATE) BETWEEN @FromDate AND @ToDate) 
					AND		(@FileType IS NULL OR IQUGC_FileTypes.Filetype = @FileType)
					AND		(@SearchTerm Is NULL OR Contains((Title, Keywords, [Description]), @SearchTerm)) 
					AND		((@SinceID IS NULL OR @SinceID = 0) OR IQUGCArchiveKey <= @SinceID )
					AND (CASE WHEN  IQUGCArchive.CategoryGUID in (SELECT t1.CategoryGUID FROM @TempTable t1) THEN
							1
					ELSE
							0
					END + 
					CASE WHEN  IQUGCArchive.SubCategory1GUID in (SELECT t1.CategoryGUID FROM @TempTable t1) THEN
							1
					ELSE
							0
					END +
					CASE WHEN  IQUGCArchive.SubCategory2GUID in (SELECT t1.CategoryGUID FROM @TempTable t1) THEN
							1
					ELSE
							0
					END +
					CASE WHEN  IQUGCArchive.SubCategory3GUID in (SELECT t1.CategoryGUID FROM @TempTable t1) THEN
							1
					ELSE
							0 
					END) >= CASE WHEN @TotalCats < 4 THEN @TotalCats ELSE 4 END
					group by IQUGC_FileTypes.FileType


				END
				ELSE
				BEGIN
					-- CreatedDT Count
	
					SELECT	
								DISTINCT CAST(IQUGCArchive.DateUploaded AS DATE) AS DateUploaded
					FROM	IQUGCArchive
								INNER JOIN IQUGC_FileTypes
										ON IQUGCArchive._FileTypeID  = IQUGC_FileTypes.ID
										AND IQUGC_FileTypes.IsActive = 1
					WHERE	(
								IQUGCArchive.CategoryGUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
								OR IQUGCArchive.SubCategory1GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
								OR IQUGCArchive.SubCategory2GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
								OR IQUGCArchive.SubCategory3GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
							)
					AND		IQUGCArchive.ClientGUID = @ClientGUID
					AND		IQUGCArchive.IsActive = 1
					AND		(@CustomerGUID IS NULL OR IQUGCArchive.CustomerGUID = @CustomerGUID)
					AND		((@FromDate is null or @ToDate is null) OR CAST(IQUGCArchive.DateUploaded AS DATE) BETWEEN @FromDate AND @ToDate) 
					AND		(@FileType IS NULL OR IQUGC_FileTypes.Filetype = @FileType)
					AND		(@SearchTerm Is NULL OR Contains((Title, Keywords, [Description]), @SearchTerm)) 
					AND		((@SinceID IS NULL OR @SinceID = 0) OR IQUGCArchiveKey <= @SinceID )

					-- Category Count

					SELECT	
								CustomCategory.CategoryGUID,
								CategoryName,
								COUNT(IQUGCArchiveKey) AS CategoryCount
					FROM	IQUGCArchive
								INNER JOIN IQUGC_FileTypes
										ON IQUGCArchive._FileTypeID  = IQUGC_FileTypes.ID
										AND IQUGC_FileTypes.IsActive = 1
	
					INNER JOIN CustomCategory
					ON		CustomCategory.CategoryGUID IN (SELECT t1.CategoryGUID FROM @TempTable t1)
					AND		CustomCategory.ClientGUID = @ClientGuid
					AND	(
							CustomCategory.CategoryGUID = IQUGCArchive.CategoryGUID
							OR CustomCategory.CategoryGUID = IQUGCArchive.SubCategory1GUID
							OR CustomCategory.CategoryGUID = IQUGCArchive.SubCategory2GUID
							OR CustomCategory.CategoryGUID = IQUGCArchive.SubCategory3GUID
						)
	
					WHERE		(
								IQUGCArchive.CategoryGUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
								OR IQUGCArchive.SubCategory1GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
								OR IQUGCArchive.SubCategory2GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
								OR IQUGCArchive.SubCategory3GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
							)
					AND		IQUGCArchive.ClientGUID = @ClientGUID
					AND		IQUGCArchive.IsActive = 1
					AND		CustomCategory.IsActive = 1
					AND		(@CustomerGUID IS NULL OR IQUGCArchive.CustomerGUID = @CustomerGUID)
					AND		((@FromDate is null or @ToDate is null) OR CAST(IQUGCArchive.DateUploaded AS DATE) BETWEEN @FromDate AND @ToDate) 
					AND		(@FileType IS NULL OR IQUGC_FileTypes.Filetype = @FileType)
					AND		(@SearchTerm Is NULL OR Contains((Title, Keywords, [Description]), @SearchTerm)) 
					AND		((@SinceID IS NULL OR @SinceID = 0) OR IQUGCArchiveKey <= @SinceID )
	
					GROUP BY CustomCategory.CategoryGUID,CategoryName
	
	
					-- Customer Count
	
					SELECT	
								IQUGCArchive.CustomerGUID,
								Customer.FirstName + ' ' + Customer.LastName AS CustomerName,
								COUNT(IQUGCArchivekeY) AS CustomerCount
					
					FROM	IQUGCArchive
								INNER JOIN IQUGC_FileTypes
										ON IQUGCArchive._FileTypeID  = IQUGC_FileTypes.ID
										AND IQUGC_FileTypes.IsActive = 1
					INNER JOIN Customer
					ON Customer.CustomerGUID = IQUGCArchive.CustomerGUID
	
					WHERE		(
								IQUGCArchive.CategoryGUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
								OR IQUGCArchive.SubCategory1GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
								OR IQUGCArchive.SubCategory2GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
								OR IQUGCArchive.SubCategory3GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
							)
					AND		IQUGCArchive.ClientGUID = @ClientGUID
					AND		IQUGCArchive.IsActive = 1
					AND		(@CustomerGUID IS NULL OR IQUGCArchive.CustomerGUID = @CustomerGUID)
					AND		((@FromDate is null or @ToDate is null) OR CAST(IQUGCArchive.DateUploaded AS DATE) BETWEEN @FromDate AND @ToDate) 
					AND		(@FileType IS NULL OR IQUGC_FileTypes.Filetype = @FileType)
					AND		(@SearchTerm Is NULL OR Contains((Title, Keywords, [Description]), @SearchTerm)) 
					AND		((@SinceID IS NULL OR @SinceID = 0) OR IQUGCArchiveKey <= @SinceID )
	
					GROUP BY IQUGCArchive.CustomerGUID,Customer.FirstName + ' ' + Customer.LastName

					-- FileType Count
					SELECT	
								IQUGC_FileTypes.FileType,
								COUNT(IQUGCArchivekeY) AS FileTypeCount
					FROM	IQUGCArchive	
								INNER JOIN IQUGC_FileTypes
												ON IQUGCArchive._FileTypeID  = IQUGC_FileTypes.ID
												AND IQUGC_FileTypes.IsActive = 1
					WHERE		(
								IQUGCArchive.CategoryGUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
								OR IQUGCArchive.SubCategory1GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
								OR IQUGCArchive.SubCategory2GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
								OR IQUGCArchive.SubCategory3GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
							)
					AND		IQUGCArchive.ClientGUID = @ClientGUID
					AND		IQUGCArchive.IsActive = 1
					AND		(@CustomerGUID IS NULL OR IQUGCArchive.CustomerGUID = @CustomerGUID)
					AND		((@FromDate is null or @ToDate is null) OR CAST(IQUGCArchive.DateUploaded AS DATE) BETWEEN @FromDate AND @ToDate) 
					AND		(@FileType IS NULL OR IQUGC_FileTypes.Filetype = @FileType)
					AND		(@SearchTerm Is NULL OR Contains((Title, Keywords, [Description]), @SearchTerm)) 
					AND		((@SinceID IS NULL OR @SinceID = 0) OR IQUGCArchiveKey <= @SinceID )
					group by IQUGC_FileTypes.FileType
				END
		END
	END
END
