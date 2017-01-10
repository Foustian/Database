-- =============================================  
-- Author:  <Author,,Name>  
-- Create date: <Create Date,,>  
-- Description: <Description,,>  
-- =============================================  
CREATE PROCEDURE [dbo].[usp_IQCore_ClipMeta_SelectFileLocation]  
	@clipXML XML
 --@ClipGUID uniqueidentifier  
AS  
BEGIN   
 SET NOCOUNT ON;  
  
 
	SELECT 
		rootelem.Clip.value('@guid','uniqueidentifier') as 'Clipguid',
		PT.FileLocation as 'FileLocation',
		PT.UGCFileLocation as 'UGCFileLocation'
	FROM 
		@clipXML.nodes('root/Clip') rootelem(Clip)
		INNER JOIN (SELECT
							*
							FROM
							(
								SELECT
									[IQCore_ClipMeta]._ClipGuid,
									[IQCore_ClipMeta].[Field],
									[IQCore_ClipMeta].[Value]
								FROM
									[IQCore_ClipMeta]
			
							) AS SourceTable
							PIVOT
							(
								Max(Value)
								FOR Field IN ([FileLocation],[UGCFileLocation])
							) AS PivotTable
					) as PT
					ON PT._ClipGuid=rootelem.Clip.value('@guid','uniqueidentifier') 
		--Where PT.FileLocation is not null
  
		--Select 
		--	Value
		--From 
		--	IQCore_ClipMeta  
		--Where
		--	Field= 'FileLocation'
		--	and _ClipGuid = @clipGUID  
  
  
END  