CREATE PROCEDURE [dbo].[usp_v4_IQService_DiscoveryExport_GetLastExportStatusByCustomerGuid]
	@CustomerGuid UNIQUEIDENTIFIER
AS
BEGIN
	SELECT 
			[Status],
			ISNULL(IQCore_RootPath.StreamSuffixPath + REPLACE(DownloadPath,'\','/'),'') AS DownloadPath,
			CASE WHEN IsSelectAll = 1 THEN SearchCriteria.query('/SearchCriteria/SearchTerm').value('.','varchar(max)') ELSE  ArticleXml.query('/MediaIDList/SearchTerm').value('.','varchar(max)') END AS SearchTerm,
			CreatedDate			
	FROM 
			IQService_DiscoveryExport 
				INNER JOIN IQCore_RootPath
					ON IQService_DiscoveryExport._RootPathID = IQCore_RootPath.ID
					AND IQCore_RootPath.IsActive = 1
	WHERE
			CustomerGuid  = @CustomerGuid
			AND IQService_DiscoveryExport.IsActive = 1
	ORDER BY
			CreatedDate DESC
	
END