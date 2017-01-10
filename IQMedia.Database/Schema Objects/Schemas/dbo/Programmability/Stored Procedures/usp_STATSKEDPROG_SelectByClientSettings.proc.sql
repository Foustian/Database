-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_STATSKEDPROG_SelectByClientSettings] 
	@ClientGuid uniqueidentifier,
	@IsAllDmaAllowed bit output,
	@IsAllStationAllowed bit output,
	@IsAllClassAllowed bit output
AS
BEGIN
	
	SET NOCOUNT ON;
	
	SELECT DISTINCT
		@IsAllDmaAllowed = convert(xml,value).exist('/SearchSettings/IQ_Dma_Set[@IsAllowAll="true"]'), 
		@IsAllClassAllowed = convert(xml,value).exist('/SearchSettings/IQ_Class_Set[@IsAllowAll="true"]'),
		@IsAllStationAllowed = convert(xml,value).exist('/SearchSettings/Station_Affiliate_Set[@IsAllowAll="true"]')
	FROM 
		IQClient_CustomSettings cs 
	WHERE 
		cs.Field ='SearchSettings' AND _ClientGuid =@ClientGuid 
	IF (@IsAllDmaAllowed = 0)
	BEGIN
		SELECT DISTINCT
			IQ_Station.Dma_Num,
			IQ_Station.Dma_Name 
		FROM 
			IQ_Station 
				INNER JOIN
			(SELECT 
				RTRIM(LTRIM(x.y.value('name[1]', 'VARCHAR(255)'))) AS iq_dma_name
			 FROM 
				IQClient_CustomSettings t
					CROSS APPLY (select  Convert(xml,t.Value) AS xml) as D(O)
					CROSS APPLY D.O.nodes('/SearchSettings/IQ_Dma_Set/IQ_Dma') AS x(y)
			 WHERE 
				
				_ClientGuid =@ClientGuid
				AND t.Field ='SearchSettings'
			 ) AS Custom_DMA
		 ON IQ_Station.Dma_Name = Custom_DMA.iq_dma_name
		 AND IsActive= 1 AND Format ='TV' ORDER BY Dma_Num
	END
	ELSE
	BEGIN
		SELECT DISTINCT
			Dma_Name,
			Dma_Num	
		FROM
			IQ_Station
		WHERE
			IsActive= 1 AND Format ='TV' 
		ORDER BY
			Dma_Num
	END

	IF (@IsAllClassAllowed = 0)	
	BEGIN
		SELECT
			SSP_IQ_Class.IQ_Class,
			SSP_IQ_Class.IQ_Class_Num
		FROM 
			SSP_IQ_Class 
				INNER JOIN
			(SELECT 
				RTRIM(LTRIM(x.y.value('num[1]', 'VARCHAR(255)'))) AS iq_class_num
			 FROM 
				IQClient_CustomSettings t
					CROSS APPLY (select  Convert(xml,t.Value) AS xml) as D(O)
					CROSS APPLY D.O.nodes('/SearchSettings/IQ_Class_Set/IQ_Class') AS x(y)
			 WHERE 
				
				_ClientGuid =@ClientGuid
				AND t.Field ='SearchSettings'
			 ) AS Custom_Class
		 ON SSP_IQ_Class.IQ_Class_Num = Custom_Class.iq_class_num
		 AND IsActive= 1 ORDER BY IQ_Class
	END
	ELSE
	BEGIN
		SELECT
			IQ_Class,
			IQ_Class_Num
		FROM
			SSP_IQ_Class
		WHERE
			IsActive= 1
		ORDER BY
			IQ_Class_Num
	END
		
	IF (@IsAllStationAllowed = 0)	
	BEGIN
		SELECT DISTINCT
			IQ_Station.Station_Affil
			,IQ_Station.Station_Affil_Num
		FROM 
			IQ_Station 
				INNER JOIN
			(SELECT 
				RTRIM(LTRIM(x.y.value('name[1]', 'VARCHAR(255)'))) AS Station_Affil_Name
			 FROM 
				IQClient_CustomSettings t
					CROSS APPLY (select  Convert(xml,t.Value) AS xml) as D(O)
					CROSS APPLY D.O.nodes('/SearchSettings/Station_Affiliate_Set/Station_Affiliate') AS x(y)
			 WHERE 
				
				_ClientGuid =@ClientGuid
				AND t.Field ='SearchSettings'
			 ) AS Custom_Station
		 ON IQ_Station.Station_Affil = Custom_Station.Station_Affil_Name
		 AND IsActive= 1 AND Format ='TV' ORDER BY Station_Affil_Num
	END
	ELSE
	BEGIN
		select DISTINCT
			Station_Affil
			,Station_Affil_Num
		from 
			IQ_Station
		where 
			IsActive=1 AND Format ='TV' 
		ORDER BY
			Station_Affil_Num
	END
END
