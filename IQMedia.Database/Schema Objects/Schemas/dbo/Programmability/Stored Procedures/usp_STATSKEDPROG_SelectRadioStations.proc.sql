-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_STATSKEDPROG_SelectRadioStations]
(
	@IQ_Dma_Num			VARCHAR(MAX),
	/*@PageNumber			INT,
	@PageSize			INT,
	@SortField			VARCHAR(250),
	@SortDirection		bit,*/
	@FromDate			date,
	@FromTime			int,
	@ToDate				date,
	@ToTime				int
)
AS
BEGIN	
	SET NOCOUNT ON;
	
	DECLARE @Query NVARCHAR(MAX)
				
	DECLARE @StartRowNo  BIGINT,
			@EndRowNo  BIGINT,
			@StartDateTime datetime,
			@EndDateTime	datetime
			
	declare	@tblStationID	table (query nvarchar(Max))
			
	Set @StartDateTime=CONVERT(Varchar(10),@FromDate)+' '+CONVERT(varchar(10),@FromTime)+':'+'0'+':'+'0'
	Set @EndDateTime=CONVERT(varchar(10),@ToDate)+' '+CONVERT(varchar(10),@ToTime)+':'+'0'+':'+'0'
			
	/*SET @StartRowNo = (@PageNumber * @PageSize) + 1
	SET @EndRowNo   = (@PageNumber * @PageSize) + @PageSize*/

   /* SET @Query = 'Insert into @tblStationID Select Station_Id From STATSKEDPROG WHERE dma_num in'+@IQ_Dma_Num+' and
					CONVERT(datetime,CONVERT(varchar(Max),STATSKEDPROG.IQ_Local_Air_Date,101) + '' ''+ REPLACE(convert(varchar(Max),convert(decimal(4,2),(convert(decimal(6,2),STATSKEDPROG.IQ_Local_Air_Time)/convert(decimal(5,2),100)))),''.'','':'')+'':00'') between '''+CONVERT(varchar(20),@StartDateTime)+''' and '''+CONVERT(Varchar(20),@EndDateTime)+''
					
	exec sp_executesql @Query*/
	
	DECLARE @IQCCKey varchar(Max),
			@TempIQCCKey varchar(Max),
			@TempDateTime datetime,
			@IndexToTime int,
			@IndexFromTime int,
			@TempFromDate date,			
			@loopCount int
			
		set @loopCount=0
			
	set @TempFromDate=@FromDate
	
	While (@FromDate<=@ToDate)
		begin
		
				if(@FromDate=@ToDate)
					begin
							set @IndexToTime=@ToTime
					end
				else
					begin
							set @IndexToTime=23
					end				
				
				if(@TempFromDate=@FromDate)
					begin				
						set @IndexFromTime=@FromTime
					end
				else
					begin
						set @IndexFromTime=0
					end
		
				While(@IndexFromTime<=@IndexToTime)
					begin
						set @loopCount=@loopCount+1
						Set @TempDateTime= CONVERT(Varchar(10),@FromDate)+' '+CONVERT(Varchar(2),@IndexFromTime)+':'+'0'+':'+'0'
					
							if(DATEDIFF(N,GETUTCDATE(),GETDATE())=300)
								begin									
								
								set @Query='SELECT @TempIQCCKey = COALESCE(@TempIQCCKey + '', '', '''') + Convert(varchar(255),RL_Station_Id)+''_''+Replace(convert(varchar(22),CONVERT(date,DATEADD(hh,((-1)*RL_STATION.gmt_adj),'+''''+Convert(Varchar(22),@TempDateTime)+''''+'))),''-'','''') + ''_'' + REPLACE(convert(varchar(5),CONVERT(datetime,DATEADD(hh,((-1)*RL_STATION.gmt_adj),'+''''+Convert(Varchar(22),@TempDateTime)+''''+')),108),'':'','''') FROM RL_STATION WHERE RL_STATION.dma_num in ('+@IQ_DMA_NUM+')'
								
								exec sp_executesql @Query, N'@TempIQCCKey varchar(max) OUTPUT', @TempIQCCKey=@TempIQCCKey OUTPUT	
									
								if(@IQCCKey is null or @IQCCKey='')							
									begin
										set @IQCCKey=@TempIQCCKey	
									end
								else
									begin
										set @IQCCKey=@IQCCKey+','+@TempIQCCKey
									end
											
								end
							else
									begin									
									
										set @Query='SELECT @TempIQCCKey = COALESCE(@TempIQCCKey + '', '', '''') + Convert(varchar(255),RL_Station_Id)+''_''+Replace(convert(varchar(22),CONVERT(date,DATEADD(hh,((-1)*RL_STATION.gmt_adj)-RL_STATION.dst_adj,'+''''+Convert(Varchar(22),@TempDateTime)+''''+'))),''-'','''') + ''_'' + REPLACE(convert(varchar(5),CONVERT(datetime,DATEADD(hh,((-1)*RL_STATION.gmt_adj)-RL_STATION.dst_adj,'+''''+Convert(Varchar(22),@TempDateTime)+''''+')),108),'':'','''') FROM RL_STATION WHERE RL_STATION.dma_num in ('+@IQ_DMA_NUM+')'
									
										exec sp_executesql @Query, N'@TempIQCCKey varchar(max) OUTPUT', @TempIQCCKey=@TempIQCCKey OUTPUT
									
									if(@IQCCKey is null or @IQCCKey='')							
										begin
											set @IQCCKey=@TempIQCCKey											
										end
									else
										begin											 
											set @IQCCKey=@IQCCKey+','+@TempIQCCKey
										end	
									
									end
						
						set @IndexFromTime=@IndexFromTime+1
						
					end	
			
			Set @FromDate=DATEADD(dd,1,@FromDate)		
			
		end
	
	--Select * from @tblStationID
	--print @Query
	select @IQCCKey	
	print @loopcount
END
