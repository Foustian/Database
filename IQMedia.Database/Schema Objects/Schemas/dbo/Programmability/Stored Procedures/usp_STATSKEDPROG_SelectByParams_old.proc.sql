
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_STATSKEDPROG_SelectByParams_old] 
(
	-- Add the parameters for the stored procedure here
	@IQ_Time_Zone		VARCHAR(250),	
	@FromDate			DATETIME,	
	@ToDate				DATETIME,
	@IQ_Dma_Num			VARCHAR(MAX),
	@IQ_Class_Num		VARCHAR(MAX),
	@IQ_Cat_Num			VARCHAR(MAX),
	@Title120			VARCHAR(MAX),
	@Desc100			VARCHAR(MAX),
	@Station_Affil_Num	VARCHAR(MAX),
	@PageNumber			INT,
	@PageSize			INT,
	@SortField			VARCHAR(250)	
)	
AS
BEGIN
				-- SET NOCOUNT ON added to prevent extra result sets from
				-- interfering with SELECT statements.
				SET NOCOUNT ON;
				
				DECLARE @Query NVARCHAR(MAX)
				
				DECLARE @StartRowNo AS BIGINT,@EndRowNo AS BIGINT
				DECLARE @SortDirection AS INT
				
				SET @SortDirection = CHARINDEX('-',@SortField)
				
				SET @SortField = REPLACE(@SortField,'-','')
				
				SET @StartRowNo = 1
				SET @EndRowNo = 1				
				
				SET @StartRowNo = (@PageNumber * @PageSize) + 1
				SET @EndRowNo   = (@PageNumber * @PageSize) + @PageSize
			 
				SET @Query = ' WITH IQMediaStatSkedProg_CTE  '
				SET @Query = @Query + ' AS ( '
			 
				SET @Query = @Query + 'Select  ROW_NUMBER() OVER (ORDER BY '
				
				IF @SortField IS NOT NULL OR @SortField <> ''
					BEGIN
					
						IF @SortField = 'DateTime'
							BEGIN
								SET @Query = @Query + ' IQ_Local_Air_Date '
							END
						ELSE
							BEGIN
								set @Query = @Query + @SortField	
							END
						
						IF @SortDirection > 0 
							BEGIN
								SET @Query = @Query + ' DESC '
							END
					END
				ELSE
					BEGIN
						SET @Query = @Query + ' Station_ID '
					END
					
				
				SET @Query = @Query + 	') as RowNumber,
										Title120,
										IQ_CC_Key
										from 
												STATSKEDPROG 
										where 
										IQ_Local_Air_Date between '''+CONVERT(varchar(Max),@FromDate)+''' and '''+CONVERT(Varchar(Max),@ToDate)+''''
										
										
				IF @IQ_Cat_Num IS NOT NULL AND @IQ_Cat_Num!=''
					begin
							SET @Query=@Query + ' AND STATSKEDPROG.IQ_Cat_Num in ('+@IQ_Cat_Num+')'
					end
					
				IF @IQ_Dma_Num IS NOT NULL AND @IQ_Dma_Num!=''
					begin
							SET @Query=@Query + ' AND STATSKEDPROG.IQ_Dma_Num in ('+@IQ_Dma_Num+')'
					end
					
				IF @IQ_Class_Num IS NOT NULL AND @IQ_Class_Num!=''
					begin
							SET @Query=@Query + ' AND STATSKEDPROG.IQ_Class_Num in ('+@IQ_Class_Num+')'
					end
					
				IF @Station_Affil_Num IS NOT NULL AND @Station_Affil_Num!=''
					begin
							SET @Query=@Query + ' AND STATSKEDPROG.Station_Affil_Num in ('+@Station_Affil_Num+')'
					end
							
				IF @Title120 IS NOT NULL AND @Title120 <> ''
					BEGIN
						SET @Query = @Query + ' AND (STATSKEDPROG.Title120  like (''%'+@Title120+'%''))'	
					END
					
				IF @Desc100 IS NOT NULL AND @Desc100 <> ''
					BEGIN
						SET @Query = @Query + ' AND (STATSKEDPROG.Desc100  like (''%'+@Desc100+'%''))'	
					END				
				
				IF @IQ_Time_Zone IS NOT NULL AND @IQ_Time_Zone <> ''
					BEGIN
						SET @Query = @Query + ' AND STATSKEDPROG.IQ_Time_Zone in('''+ @IQ_Time_Zone +''')'
					END
					
				SET @Query = @Query + ') '
					
				SET  @Query = @Query + ' SELECT * FROM IQMediaStatSkedProg_CTE Where RowNumber >=' + CAST(@StartRowNo as VARCHAR) + ' AND RowNumber <= ' + CAST(@EndRowNo as VARCHAR)						
				
				Print @Query
				
				EXEC SP_EXECUTESQL @Query
				
				
				-- For Count --
				
				DECLARE @CountQuery NVARCHAR(Max)
				
				 set @CountQuery='Select 
											count(STATSKEDPROG.STATSKEDPROGKey) as TotalRowCount 
								  from 
											STATSKEDPROG
								  where 
			    							IQ_Local_Air_Date between '''+CONVERT(varchar(Max),@FromDate)+''' and '''+CONVERT(Varchar(Max),@ToDate)
			    						
				IF @IQ_Cat_Num IS NOT NULL AND @IQ_Cat_Num!=''
					begin
							SET @CountQuery=@CountQuery + ' AND STATSKEDPROG.IQ_Cat_Num in ('+@IQ_Cat_Num+')'
					end
					
				IF @IQ_Dma_Num IS NOT NULL AND @IQ_Dma_Num!=''
					begin
							SET @CountQuery=@CountQuery + ' AND STATSKEDPROG.IQ_Dma_Num in ('+@IQ_Dma_Num+')'
					end
					
				IF @IQ_Class_Num IS NOT NULL AND @IQ_Class_Num!=''
					begin
							SET @CountQuery=@CountQuery + ' AND STATSKEDPROG.IQ_Class_Num in ('+@IQ_Class_Num+')'
					end
					
				IF @Station_Affil_Num IS NOT NULL AND @Station_Affil_Num!=''
					begin
							SET @CountQuery=@CountQuery + ' AND STATSKEDPROG.Station_Affil_Num in ('+@Station_Affil_Num+')'
					end
							
				IF @Title120 IS NOT NULL AND @Title120 <> ''
					BEGIN
						SET @CountQuery = @CountQuery + ' AND (STATSKEDPROG.Title120  like (''%'+@Title120+'%''))'	
					END
					
				IF @Desc100 IS NOT NULL AND @Desc100 <> ''
					BEGIN
						SET @CountQuery = @CountQuery + ' AND (STATSKEDPROG.Desc100  like (''%'+@Desc100+'%''))'	
					END
				
				IF @IQ_Time_Zone IS NOT NULL AND @IQ_Time_Zone <> ''
					BEGIN
						SET @CountQuery = @CountQuery + ' AND STATSKEDPROG.IQ_Time_Zone in('''+ @IQ_Time_Zone +''')'
					END
					
				EXEC SP_EXECUTESQL @CountQuery
					
				--EXEC sp_executesql 
				--	@query = @CountQuery, 
				--	@params = N'@TotalRowCount INT OUTPUT', 
				--	@TotalRowCount = @TotalRowCount OUTPUT 
   
   END