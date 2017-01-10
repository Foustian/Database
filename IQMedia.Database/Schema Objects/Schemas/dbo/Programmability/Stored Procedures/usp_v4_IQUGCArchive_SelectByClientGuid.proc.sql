-- =============================================
-- Author:		<Author,,Name>
-- Create date: 26 July 2013
-- Description:	Find all results based on ClientGuid
-- =============================================
CREATE PROCEDURE [dbo].[usp_v4_IQUGCArchive_SelectByClientGuid]
	@ClientGuid		UNIQUEIDENTIFIER,
	@FromRecordID	BIGINT,
	@FromDate		DATE,
	@ToDate			DATE,
	@SearchTerm		VARCHAR(4000),
	@CategoryGUID	xml,
	@CustomerGUID	UNIQUEIDENTIFIER,
	@PageSize		INT,
	@IsAsc			BIT,
	@SortColumn		VARCHAR(100),
	@IsEnableFilter	BIT,
	@SelectionType	varchar(3),
	@FileType		varchar(20),
	@SinceID		BIGINT OUTPUT,
	@TotalResults	BIGINT OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @TotalCats  int 					
	DECLARE @TempTable table(CategoryGuid uniqueidentifier)

	-- Select Total Results Count
	IF(@SearchTerm IS NULL)
	BEGIN
		IF(@CategoryGUID IS NULL)
		BEGIN
			SELECT	@SinceID = CASE WHEN (@SinceID IS NULL OR @SinceID=0) THEN MAX(IQUGCArchiveKey) ELSE @SinceID END,
				@TotalResults = COUNT(IQUGCArchiveKey)
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
	
	
			-- Select Results
			;WITH CTE_IQUGCArchive AS
			(
					SELECT	
							CASE
								WHEN  @SortColumn = 'CreatedDate' AND @IsAsc = 1 THEN ROW_NUMBER() OVER(ORDER BY DateUploaded)
								WHEN  @SortColumn = 'CreatedDate' AND @IsAsc = 0 THEN ROW_NUMBER() OVER(ORDER BY DateUploaded DESC)
								WHEN  @SortColumn = 'AirDate' AND @IsAsc = 1 THEN ROW_NUMBER() OVER(ORDER BY AirDate)
								ELSE  ROW_NUMBER() OVER(ORDER BY AirDate DESC)
							END AS RowNo,
							IQUGCArchive.IQUGCArchiveKey,
							IQUGCArchive.UGCGUID,
							IQUGCArchive.Title,
							IQUGCArchive.DateUploaded,
							IQUGCArchive.CreateDTTimeZone,
							IQUGCArchive.AirDate,
							IQUGCArchive.CategoryGUID,
							IQUGCArchive.[Description],
							IQUGCArchive.ThumbnailImage,
							IQUGC_FileTypes.Filetype,
							CASE WHEN IQUGC_FileTypes.FileType = 'VMedia' THEN NULL ELSE (SELECT ISNULL(StreamSuffixPath + REPLACE(IQUGCArchive.Location,'\','/'),'') FROM IQCore_RootPath Where ID = IQUGCArchive._RootPathID) END as MediaUrl
					
					FROM	IQUGCArchive
								INNER JOIN IQUGC_FileTypes
									ON IQUGCArchive._FileTypeID  = IQUGC_FileTypes.ID
									AND IQUGC_FileTypes.IsActive = 1
					WHERE	IQUGCArchive.ClientGUID = @ClientGUID
					AND		IQUGCArchive.IsActive = 1
					AND		(@CustomerGUID IS NULL OR IQUGCArchive.CustomerGUID = @CustomerGUID)
					AND		(@FileType IS NULL OR IQUGC_FileTypes.Filetype = @FileType)
					AND		((@FromDate is null or @ToDate is null) OR CAST(IQUGCArchive.DateUploaded AS DATE) BETWEEN @FromDate AND @ToDate) 
					AND		IQUGCArchiveKey <= @SinceID
			
			)
			SELECT * FROM CTE_IQUGCArchive WHERE RowNo > @FromRecordID AND RowNo <= (@FromRecordID + @PageSize)
			Order By RowNo
		END	
		ELSE
		BEGIN

			INSERT INTO @TempTable
			SELECT cat.item.value('@guid','uniqueidentifier') FROM @CategoryGUID.nodes('list/item') as cat(item)

			SELECT @TotalCats = count(*) FROM @TempTable as t

			IF(UPPER(@SelectionType) = 'AND')
			BEGIN
				SELECT	@SinceID = CASE WHEN (@SinceID IS NULL OR @SinceID=0) THEN MAX(IQUGCArchiveKey) ELSE @SinceID END,
					@TotalResults = COUNT(IQUGCArchiveKey)
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
								0 END
					) >= CASE WHEN @TotalCats < 4 THEN @TotalCats ELSE 4 END


				-- Select Results
				;WITH CTE_IQUGCArchive AS
				(
						SELECT	
								CASE
									WHEN  @SortColumn = 'CreatedDate' AND @IsAsc = 1 THEN ROW_NUMBER() OVER(ORDER BY DateUploaded)
									WHEN  @SortColumn = 'CreatedDate' AND @IsAsc = 0 THEN ROW_NUMBER() OVER(ORDER BY DateUploaded DESC)
									WHEN  @SortColumn = 'AirDate' AND @IsAsc = 1 THEN ROW_NUMBER() OVER(ORDER BY AirDate)
									ELSE  ROW_NUMBER() OVER(ORDER BY AirDate DESC)
								END AS RowNo,
								IQUGCArchive.IQUGCArchiveKey,
								IQUGCArchive.UGCGUID,
								IQUGCArchive.Title,
								IQUGCArchive.DateUploaded,
								IQUGCArchive.CreateDTTimeZone,
								IQUGCArchive.AirDate,
								IQUGCArchive.CategoryGUID,
								IQUGCArchive.[Description],
								IQUGCArchive.ThumbnailImage,
								IQUGC_FileTypes.Filetype,
								CASE WHEN IQUGC_FileTypes.FileType = 'VMedia' THEN NULL ELSE (SELECT ISNULL(StreamSuffixPath + REPLACE(IQUGCArchive.Location,'\','/'),'') FROM IQCore_RootPath Where ID = IQUGCArchive._RootPathID) END as MediaUrl
					
						FROM	
								IQUGCArchive
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
						AND		IQUGCArchiveKey <= @SinceID
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
								0 END
					) >= CASE WHEN @TotalCats < 4 THEN @TotalCats ELSE 4 END
			
				)
				SELECT * FROM CTE_IQUGCArchive WHERE RowNo > @FromRecordID AND RowNo <= (@FromRecordID + @PageSize)
				Order By RowNo
			END
			ELSE
			BEGIN
				SELECT	@SinceID = CASE WHEN (@SinceID IS NULL OR @SinceID=0) THEN MAX(IQUGCArchiveKey) ELSE @SinceID END,
					@TotalResults = COUNT(IQUGCArchiveKey)
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

				;WITH CTE_IQUGCArchive AS
				(
						SELECT	
								CASE
									WHEN  @SortColumn = 'CreatedDate' AND @IsAsc = 1 THEN ROW_NUMBER() OVER(ORDER BY DateUploaded)
									WHEN  @SortColumn = 'CreatedDate' AND @IsAsc = 0 THEN ROW_NUMBER() OVER(ORDER BY DateUploaded DESC)
									WHEN  @SortColumn = 'AirDate' AND @IsAsc = 1 THEN ROW_NUMBER() OVER(ORDER BY AirDate)
									ELSE  ROW_NUMBER() OVER(ORDER BY AirDate DESC)
								END AS RowNo,
								IQUGCArchive.IQUGCArchiveKey,
								IQUGCArchive.UGCGUID,
								IQUGCArchive.Title,
								IQUGCArchive.DateUploaded,
								IQUGCArchive.CreateDTTimeZone,
								IQUGCArchive.AirDate,
								IQUGCArchive.CategoryGUID,
								IQUGCArchive.[Description],
								IQUGCArchive.ThumbnailImage,
								IQUGC_FileTypes.Filetype,
								CASE WHEN IQUGC_FileTypes.FileType = 'VMedia' THEN NULL ELSE (SELECT ISNULL(StreamSuffixPath + REPLACE(IQUGCArchive.Location,'\','/'),'') FROM IQCore_RootPath Where ID = IQUGCArchive._RootPathID) END as MediaUrl
					
						FROM	
								IQUGCArchive
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
						AND		IQUGCArchiveKey <= @SinceID
				)
				SELECT * FROM CTE_IQUGCArchive WHERE RowNo > @FromRecordID AND RowNo <= (@FromRecordID + @PageSize)
				Order By RowNo
			END
		END
	END
	ELSE
	BEGIN
		IF(@CategoryGUID IS NULL)
		BEGIN
			SELECT	@SinceID = CASE WHEN (@SinceID IS NULL OR @SinceID=0) THEN MAX(IQUGCArchiveKey) ELSE @SinceID END,
				@TotalResults = COUNT(IQUGCArchiveKey)
			FROM	IQUGCArchive
						INNER JOIN IQUGC_FileTypes
							ON IQUGCArchive._FileTypeID  = IQUGC_FileTypes.ID
							AND IQUGC_FileTypes.IsActive = 1
			WHERE	IQUGCArchive.ClientGUID = @ClientGUID
			AND		IQUGCArchive.IsActive = 1
			AND		(@CustomerGUID IS NULL OR IQUGCArchive.CustomerGUID = @CustomerGUID)
			AND		((@FromDate is null or @ToDate is null) OR CAST(IQUGCArchive.DateUploaded AS DATE) BETWEEN @FromDate AND @ToDate)
			AND		(@FileType IS NULL OR IQUGC_FileTypes.Filetype = @FileType) 
			AND		(@SearchTerm Is NULL OR 
						--(Title LIKE '%' + @SearchTerm +'%' OR [Description] LIKE '%' + @SearchTerm +'%' OR Keywords LIKE '%' + @SearchTerm +'%')
						Contains((Title,[Description],Keywords ),@SearchTerm) 
					)
			AND		((@SinceID IS NULL OR @SinceID = 0) OR IQUGCArchiveKey <= @SinceID )
	
	
			-- Select Results
			;WITH CTE_IQUGCArchive AS
			(
					SELECT	
							CASE
								WHEN  @SortColumn = 'CreatedDate' AND @IsAsc = 1 THEN ROW_NUMBER() OVER(ORDER BY DateUploaded)
								WHEN  @SortColumn = 'CreatedDate' AND @IsAsc = 0 THEN ROW_NUMBER() OVER(ORDER BY DateUploaded DESC)
								WHEN  @SortColumn = 'AirDate' AND @IsAsc = 1 THEN ROW_NUMBER() OVER(ORDER BY AirDate)
								ELSE  ROW_NUMBER() OVER(ORDER BY AirDate DESC)
							END AS RowNo,
							IQUGCArchive.IQUGCArchiveKey,
							IQUGCArchive.UGCGUID,
							IQUGCArchive.Title,
							IQUGCArchive.DateUploaded,
							IQUGCArchive.CreateDTTimeZone,
							IQUGCArchive.AirDate,
							IQUGCArchive.CategoryGUID,
							IQUGCArchive.[Description],
							IQUGCArchive.ThumbnailImage,
							IQUGC_FileTypes.Filetype,
							CASE WHEN IQUGC_FileTypes.FileType = 'VMedia' THEN NULL ELSE (SELECT ISNULL(StreamSuffixPath + REPLACE(IQUGCArchive.Location,'\','/'),'') FROM IQCore_RootPath Where ID = IQUGCArchive._RootPathID) END as MediaUrl
					
						FROM	
								IQUGCArchive
									INNER JOIN IQUGC_FileTypes
										ON IQUGCArchive._FileTypeID  = IQUGC_FileTypes.ID
										AND IQUGC_FileTypes.IsActive = 1

					WHERE	IQUGCArchive.ClientGUID = @ClientGUID
					AND		IQUGCArchive.IsActive = 1
					AND		(@CustomerGUID IS NULL OR IQUGCArchive.CustomerGUID = @CustomerGUID)
					AND		((@FromDate is null or @ToDate is null) OR CAST(IQUGCArchive.DateUploaded AS DATE) BETWEEN @FromDate AND @ToDate) 
					AND		(@SearchTerm Is NULL OR Contains((Title,[Description],Keywords ),@SearchTerm))
					AND		(@FileType IS NULL OR IQUGC_FileTypes.Filetype = @FileType)
					--AND		Contains((Title, Keywords, [Description]), @SearchTerm) 
					AND		IQUGCArchiveKey <= @SinceID
			
			)
			SELECT * FROM CTE_IQUGCArchive WHERE RowNo > @FromRecordID AND RowNo <= (@FromRecordID + @PageSize)
			Order By RowNo
		END	
		ELSE
		BEGIN

			INSERT INTO @TempTable
			SELECT cat.item.value('@guid','uniqueidentifier') FROM @CategoryGUID.nodes('list/item') as cat(item)

			SELECT @TotalCats = count(*) FROM @TempTable as t

			IF(UPPER(@SelectionType) = 'AND')
			BEGIN
				SELECT	@SinceID = CASE WHEN (@SinceID IS NULL OR @SinceID=0) THEN MAX(IQUGCArchiveKey) ELSE @SinceID END,
					@TotalResults = COUNT(IQUGCArchiveKey)
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
				AND		(@SearchTerm Is NULL OR Contains((Title,[Description],Keywords ),@SearchTerm))
				--AND		Contains((Title, Keywords, [Description]), @SearchTerm) 
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
								0 END
					) >= CASE WHEN @TotalCats < 4 THEN @TotalCats ELSE 4 END


				-- Select Results
				;WITH CTE_IQUGCArchive AS
				(
						SELECT	
								CASE
									WHEN  @SortColumn = 'CreatedDate' AND @IsAsc = 1 THEN ROW_NUMBER() OVER(ORDER BY DateUploaded)
									WHEN  @SortColumn = 'CreatedDate' AND @IsAsc = 0 THEN ROW_NUMBER() OVER(ORDER BY DateUploaded DESC)
									WHEN  @SortColumn = 'AirDate' AND @IsAsc = 1 THEN ROW_NUMBER() OVER(ORDER BY AirDate)
									ELSE  ROW_NUMBER() OVER(ORDER BY AirDate DESC)
								END AS RowNo,
								IQUGCArchive.IQUGCArchiveKey,
								IQUGCArchive.UGCGUID,
								IQUGCArchive.Title,
								IQUGCArchive.DateUploaded,
								IQUGCArchive.CreateDTTimeZone,
								IQUGCArchive.AirDate,
								IQUGCArchive.CategoryGUID,
								IQUGCArchive.[Description],
								IQUGCArchive.ThumbnailImage,
								IQUGC_FileTypes.Filetype,
								CASE WHEN IQUGC_FileTypes.FileType = 'VMedia' THEN NULL ELSE (SELECT ISNULL(StreamSuffixPath + REPLACE(IQUGCArchive.Location,'\','/'),'') FROM IQCore_RootPath Where ID = IQUGCArchive._RootPathID) END as MediaUrl
					
						FROM	
								IQUGCArchive
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
						AND		(@SearchTerm Is NULL OR Contains((Title,[Description],Keywords ),@SearchTerm))
						--AND		Contains((Title, Keywords, [Description]), @SearchTerm) 
						AND		IQUGCArchiveKey <= @SinceID
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
								0 END
					) >= CASE WHEN @TotalCats < 4 THEN @TotalCats ELSE 4 END
			
				)
				SELECT * FROM CTE_IQUGCArchive WHERE RowNo > @FromRecordID AND RowNo <= (@FromRecordID + @PageSize)
				Order By RowNo
			END
			ELSE
			BEGIN
				SELECT	@SinceID = CASE WHEN (@SinceID IS NULL OR @SinceID=0) THEN MAX(IQUGCArchiveKey) ELSE @SinceID END,
					@TotalResults = COUNT(IQUGCArchiveKey)
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
				AND		(@SearchTerm Is NULL OR Contains((Title,[Description],Keywords ),@SearchTerm))
				--AND		Contains((Title, Keywords, [Description]), @SearchTerm) 
				AND		((@SinceID IS NULL OR @SinceID = 0) OR IQUGCArchiveKey <= @SinceID )

				;WITH CTE_IQUGCArchive AS
				(
						SELECT	
								CASE
									WHEN  @SortColumn = 'CreatedDate' AND @IsAsc = 1 THEN ROW_NUMBER() OVER(ORDER BY DateUploaded)
									WHEN  @SortColumn = 'CreatedDate' AND @IsAsc = 0 THEN ROW_NUMBER() OVER(ORDER BY DateUploaded DESC)
									WHEN  @SortColumn = 'AirDate' AND @IsAsc = 1 THEN ROW_NUMBER() OVER(ORDER BY AirDate)
									ELSE  ROW_NUMBER() OVER(ORDER BY AirDate DESC)
								END AS RowNo,
								IQUGCArchive.IQUGCArchiveKey,
								IQUGCArchive.UGCGUID,
								IQUGCArchive.Title,
								IQUGCArchive.DateUploaded,
								IQUGCArchive.CreateDTTimeZone,
								IQUGCArchive.AirDate,
								IQUGCArchive.CategoryGUID,
								IQUGCArchive.[Description],
								IQUGCArchive.ThumbnailImage,
								IQUGC_FileTypes.Filetype,
								CASE WHEN IQUGC_FileTypes.FileType = 'VMedia' THEN NULL ELSE (SELECT ISNULL(StreamSuffixPath + REPLACE(IQUGCArchive.Location,'\','/'),'') FROM IQCore_RootPath Where ID = IQUGCArchive._RootPathID) END as MediaUrl
					
						FROM	
								IQUGCArchive
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
						AND		(@SearchTerm Is NULL OR Contains((Title,[Description],Keywords ),@SearchTerm))
						--AND		Contains((Title, Keywords, [Description]), @SearchTerm) 
						AND		IQUGCArchiveKey <= @SinceID
				)
				SELECT * FROM CTE_IQUGCArchive WHERE RowNo > @FromRecordID AND RowNo <= (@FromRecordID + @PageSize)
				Order By RowNo
			END
		END
	END

	IF @IsEnableFilter = 1
		BEGIN
			EXEC [dbo].[usp_v4_IQUGCArchive_SelectFilter] @FromDate,@ToDate,@SearchTerm,@CategoryGUID,@CustomerGUID,@ClientGuid,@SelectionType,@FileType,@SinceID
		END
	
	
END
