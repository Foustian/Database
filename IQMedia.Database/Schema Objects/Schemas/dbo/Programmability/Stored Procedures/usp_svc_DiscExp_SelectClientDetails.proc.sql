CREATE PROCEDURE [dbo].[usp_svc_DiscExp_SelectClientDetails]
(
	@CustomerGUID	UNIQUEIDENTIFIER
)
AS
BEGIN	
	SET NOCOUNT ON;
	
	DECLARE @ClientGUID UNIQUEIDENTIFIER,			
			@TimeZone	VARCHAR(8),
			@IsNielsenData BIT=0,
			@IsCompeteData	BIT=0,
			@ClientID	BIGINT,
			@CustomerID	BIGINT,
			@GMT	DECIMAL(8,2),
			@DST	DECIMAL(18,2)
						
	SELECT
			@ClientGUID=ClientGUID,
			@TimeZone=Client.TimeZone,
			@IsCompeteData=(SELECT CASE WHEN ClientRole.IsAccess=1 AND CustomerRole.IsAccess=1 THEN 1 ELSE 0 END FROM [ROLE] INNER JOIN ClientRole	ON [ROLE].RoleKey=ClientRole.RoleID AND ClientRole.ClientID=Client.ClientKey INNER JOIN CustomerRole ON [ROLE].RoleKey=CustomerRole.RoleID AND CustomerRole.CustomerID=Customer.CustomerKey WHERE [ROLE].RoleName='CompeteData' AND [ROLE].IsActive=1),
			@IsNielsenData=(SELECT CASE WHEN ClientRole.IsAccess=1 AND CustomerRole.IsAccess=1 THEN 1 ELSE 0 END FROM [ROLE] INNER JOIN ClientRole	ON [ROLE].RoleKey=ClientRole.RoleID AND ClientRole.ClientID=Client.ClientKey INNER JOIN CustomerRole ON [ROLE].RoleKey=CustomerRole.RoleID AND CustomerRole.CustomerID=Customer.CustomerKey WHERE [ROLE].RoleName='NielsenData' AND [ROLE].IsActive=1),
			@ClientID=ClientKey,
			@CustomerID=CustomerKey,
			@GMT=gmt,
			@DST=dst
	FROM
			 Client							
				INNER JOIN Customer
					ON Customer.ClientID=Client.ClientKey
					AND Customer.CustomerGUID=@CustomerGUID
	WHERE
			Client.IsActive=1
		AND	Customer.IsActive=1
		
	DECLARE @DefaultClient UNIQUEIDENTIFIER = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER)
	
	;WITH TEMP_ClientSettings AS
	(
		SELECT
				ROW_NUMBER() OVER (PARTITION BY Field ORDER BY IQClient_CustomSettings._ClientGuid DESC) AS RowNum,
				Field,
				VALUE
		FROM
				IQClient_CustomSettings
		WHERE
				(IQClient_CustomSettings._ClientGuid=@ClientGuid OR IQClient_CustomSettings._ClientGuid = @DefaultClient)
				AND IQClient_CustomSettings.Field IN ('v4MaxDiscoveryExportItems','v4MaxFeedsExportItems','IQLicense','IQTVRegion','IQTVCountry','TVLowThreshold','TVHighThreshold','NMLowThreshold','NMHighThreshold','SMLowThreshold','SMHighThreshold','TwitterLowThreshold','TwitterHighThreshold','PQLowThreshold','PQHighThreshold','UseProminenceMediaValue','IQRawMediaExpiration')
	)


	SELECT 
			[v4MaxDiscoveryExportItems] AS ExportLimit,
			[v4MaxFeedsExportItems] AS FeedsExportLimit,
			[IQLicense] AS License,
			[IQTVRegion] AS Region,
			[IQTVCountry] AS Country,
			[TVLowThreshold],
			[TVHighThreshold],
			[NMLowThreshold],
			[NMHighThreshold],
			[SMLowThreshold],
			[SMHighThreshold],
			[TwitterLowThreshold],
			[TwitterHighThreshold],
			[PQLowThreshold],
			[PQHighThreshold],
			[UseProminenceMediaValue],
			[IQRawMediaExpiration],
			@ClientGUID AS ClientGUID,
			@TimeZone AS TimeZone,
			ISNULL(@IsNielsenData,0) AS IsNielsenData,
			ISNULL(@IsCompeteData,0) AS IsCompeteData,
			@GMT AS GMTHours,
			@DST AS DSTHours
	FROM
			(
				SELECT 
						Field,
						VALUE 
				FROM 
						TEMP_ClientSettings	
				WHERE	
						RowNum =1
			) 
			AS a PIVOT 
			(
				MAX(VALUE) 
				FOR Field IN([v4MaxDiscoveryExportItems],[v4MaxFeedsExportItems],[IQLicense],[IQTVRegion],[IQTVCountry],[TVLowThreshold],[TVHighThreshold],[NMLowThreshold],[NMHighThreshold],[SMLowThreshold],[SMHighThreshold],[TwitterLowThreshold],[TwitterHighThreshold],[PQLowThreshold],[PQHighThreshold],[UseProminenceMediaValue],[IQRawMediaExpiration])	
			) b

END