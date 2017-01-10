-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_STATSKEDPROG_SelectByString] 
	-- Add the parameters for the stored procedure here
	@IQ_Time_Zone varchar(250),	
	@FromDate datetime,	
	@ToDate datetime,
	@IQ_Dma_Num  varchar(Max),
	@IQ_Class varchar(Max),
	@IQ_Cat varchar(MAx),
	@Title120 varchar(Max),
	@Station_Affil varchar(Max)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @Query nvarchar(Max)
	
	--STATSKEDPROG.Air_Date in  ('+CONVERT(varchar,'''' + cast(@Air_Date as varchar(25)) +'''',101)+','+CONVERT(varchar,'''' + cast(@Air_ToDate as varchar(25)) +'''',101)+') and
	--	STATSKEDPROG.IQ_Air_Time in ('''+@IQ_Air_Time +''','''+@IQ_Air_ToTime+''') and
	IF @IQ_Time_Zone IS NULL or @IQ_Time_Zone=''
	BEGIN
	
		IF @Title120 is null or @Title120=''
			begin
	
					set @Query = 'Select Station_ID from STATSKEDPROG where 
    
					CONVERT(datetime,CONVERT(varchar(Max),STATSKEDPROG.IQ_Local_Air_Date,101) + '' ''+ REPLACE(convert(varchar(Max),convert(decimal(4,2),(convert(decimal(6,2),STATSKEDPROG.IQ_Local_Air_Time)/convert(decimal(5,2),100)))),''.'','':'')+'':00'') between '''+CONVERT(varchar(Max),@FromDate)+''' and '''+CONVERT(varchar(Max),@ToDate)+''' and
					STATSKEDPROG.IQ_Dma_Num in ('+@IQ_Dma_Num+') and
					STATSKEDPROG.IQ_Cat in ('+@IQ_Cat+') and
					STATSKEDPROG.IQ_Class in ('+@IQ_Class+')and
					STATSKEDPROG.Station_Affil in ('+@Station_Affil+') '		
			END
		ELSE
			BEGIN
					
					set @Query = 'Select Station_ID from STATSKEDPROG where    
					
					CONVERT(datetime,CONVERT(varchar(Max),STATSKEDPROG.IQ_Local_Air_Date,101) + '' ''+ REPLACE(convert(varchar(Max),convert(decimal(4,2),(convert(decimal(6,2),STATSKEDPROG.IQ_Local_Air_Time)/convert(decimal(5,2),100)))),''.'','':'')+'':00'') between '''+CONVERT(varchar(Max),@FromDate)+''' and '''+CONVERT(Varchar(Max),@ToDate)+''' and
					STATSKEDPROG.IQ_Dma_Num in ('+@IQ_Dma_Num+') and
					STATSKEDPROG.IQ_Cat in ('+@IQ_Cat+') and
					STATSKEDPROG.IQ_Class in ('+@IQ_Class+') and
					STATSKEDPROG.Station_Affil in ('+@Station_Affil+')and
					(STATSKEDPROG.Title120  like (''%'+@Title120+'%'') or STATSKEDPROG.Desc100  like (''%'+@Title120+'%''))'
					
			END
		 
		exec sp_executesql @Query	
		
		
		END
	ELSE
		BEGIN	
			IF @Title120 is null or @Title120=''
				begin
				
						set @Query = 'Select Station_ID from STATSKEDPROG where 
					    
							STATSKEDPROG.IQ_Time_Zone in('''+ @IQ_Time_Zone +''') and
							CONVERT(datetime,CONVERT(varchar(Max),STATSKEDPROG.IQ_Local_Air_Date,101) + '' ''+ REPLACE(convert(varchar(Max),convert(decimal(4,2),(convert(decimal(6,2),STATSKEDPROG.IQ_Local_Air_Time)/convert(decimal(5,2),100)))),''.'','':'')+'':00'') between '''+CONVERT(varchar(Max),@FromDate)+''' and '''+CONVERT(Varchar(Max),@ToDate)+''' and
							STATSKEDPROG.IQ_Dma_Num in ('+@IQ_Dma_Num+') and
							STATSKEDPROG.IQ_Cat in ('+@IQ_Cat+') and
							STATSKEDPROG.IQ_Class in ('+@IQ_Class+')and
							STATSKEDPROG.Station_Affil in ('+@Station_Affil+')'							
							
				end
			ELSE
				BEGIN
				
						set @Query = 'Select Station_ID from STATSKEDPROG where 
					    
							STATSKEDPROG.IQ_Time_Zone in('''+ @IQ_Time_Zone +''') and
							CONVERT(datetime,CONVERT(varchar(Max),STATSKEDPROG.IQ_Local_Air_Date,101) + '' ''+ REPLACE(convert(varchar(Max),convert(decimal(4,2),(convert(decimal(6,2),STATSKEDPROG.IQ_Local_Air_Time)/convert(decimal(5,2),100)))),''.'','':'')+'':00'') between '''+CONVERT(varchar(Max),@FromDate)+''' and '''+CONVERT(Varchar(Max),@ToDate)+''' and
							STATSKEDPROG.IQ_Dma_Num in ('+@IQ_Dma_Num+') and
							STATSKEDPROG.IQ_Cat in ('+@IQ_Cat+') and
							STATSKEDPROG.IQ_Class in ('+@IQ_Class+') and
							STATSKEDPROG.Station_Affil in ('+@Station_Affil+')and
							(STATSKEDPROG.Title120  like (''%'+@Title120+'%'') or STATSKEDPROG.Desc100  like (''%'+@Title120+'%''))'
				
				END
			
			exec sp_executesql @Query		
			 
    END
   
    END

