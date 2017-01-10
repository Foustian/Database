CREATE PROCEDURE [dbo].[usp_ArchiveClip_InsertList]
(
	@XmlData			xml
)
AS
BEGIN	
	SET NOCOUNT OFF;

	begin transaction
	begin try

		DECLARE @CppDayPart2Val float
	SELECT @CppDayPart2Val = cppvalue FROM IQ_SQAD Where daypartid = 2 and SQADMarketID = 997
		
		INSERT into [dbo].[ArchiveClip]
		(
				ClipID,
				ClipLogo,
				ClipTitle,
				ClipDate,
				FirstName,
				LastName,
				CustomerID,
				Category,
				SubCategory1GUID,
				SubCategory2GUID,
				SubCategory3GUID,				
				[Description],
				[Keywords],
				ClosedCaption,
				ClipCreationDate,				
				CreatedDate,
				ModifiedDate,
				IsActive,
				ThumbnailImagePath,
				CustomerGUID,
				ClientGUID,
				CategoryGUID,
				IQ_CC_Key,
				StartOffset,
				Nielsen_Audience,
				IQAdShareValue,
				Nielsen_Result,
				CreatedBy,
				ModifiedBy
		)

		select 
					tblXml.c.value('@ClipID','uniqueidentifier') as [ClipID],
					tblXml.c.value('@ClipLogo','varchar(150)') as [ClipLogo],
					tblXml.c.value('@ClipTitle','varchar(255)') as [ClipTitle],
					tblXml.c.value('@ClipDate','datetime') as [ClipDate],
					Customer.FirstName as [FirstName],
					Customer.LastName as [LastName],
					tblXml.c.value('@CustomerID','bigint') as [CustomerID],
					tblXml.c.value('@Category','varchar(50)') as [Category],
					tblXml.c.value('@SubCategory1GUID','uniqueidentifier') as [SubCategory1GUID],
					tblXml.c.value('@SubCategory2GUID','uniqueidentifier') as [SubCategory2GUID],
					tblXml.c.value('@SubCategory3GUID','uniqueidentifier') as [SubCategory3GUID],
					tblXml.c.value('@Description','varchar(max)') as [Description],
					tblXml.c.value('@Keywords','varchar(max)') as [Keywords],
					tblXml.c.value('@ClosedCaption','varchar(max)') as [ClosedCaption],
					tblXml.c.value('@ClipCreationDate','datetime') as [ClipCreationDate],
					ISNULL(tblXml.c.value('@CreatedDate','datetime'),GETDATE()) as [CreatedDate],
					ISNULL(tblXml.c.value('@ModifiedDate','datetime'),GETDATE()) as [ModifiedDate],
					ISNULL(tblXml.c.value('@IsActive','bit'),1) as [IsActive],
					tblXml.c.value('@ThumbnailImagePath','varchar(500)') as ThumbnailImagePath,
					tblXml.c.value('@CustomerGUID','uniqueidentifier') as [CustomerGUID],
					tblXml.c.value('@ClientGUID','uniqueidentifier') as [ClientGUID],
					tblXml.c.value('@CategoryGUID','uniqueidentifier') as [CategoryGUID],
					tblXml.c.value('@IQ_CC_Key','varchar(28)') as [IQ_CC_Key],
					[IQCore_Clip].StartOffset,
					CASE
						WHEN  AUDIENCE = 0 OR AUDIENCE IS NULL THEN
							CAST((Avg_Ratings_Pt) * (IQ_Station.UNIVERSE) AS int)
						ELSE 
							AUDIENCE
						END
					as AUDIENCE,
					
					CASE WHEN  SQAD_SHAREVALUE = 0 OR SQAD_SHAREVALUE IS NULL THEN
						CONVERT(DECIMAL(18,2),Avg_Ratings_Pt * 100* (Cast(([IQCore_Clip].EndOffset - [IQCore_Clip].StartOffset + 1) as Decimal(18,2)) /30 ) * (SELECT CONVERT(float,ISNULL((select Value from IQClient_CustomSettings where Field = 'Multiplier' and _ClientGuid = tblXml.c.value('@ClientGUID','uniqueidentifier')),(select Value from IQClient_CustomSettings where Field = 'Multiplier' and _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))))) * 
										CASE WHEN IQ_Station.SQADMARKETID = 997 AND IQ_Nielsen_Averages.DAYPARTID = 6 THEN
											@CppDayPart2Val
										ELSE
											(SELECT CPPVALUE FROM IQ_SQAD WHERE IQ_SQAD.SQADMARKETID = IQ_Station.SQADMARKETID AND IQ_SQAD.DAYPARTID = IQ_Nielsen_Averages.DAYPARTID)
										END)
					ELSE
						CONVERT(DECIMAL(18,2), SQAD_SHAREVALUE * (Cast(([IQCore_Clip].EndOffset - [IQCore_Clip].StartOffset + 1) as Decimal(18,2)) /30 ) * (SELECT CONVERT(float,ISNULL((select Value from IQClient_CustomSettings where Field = 'Multiplier' and _ClientGuid = tblXml.c.value('@ClientGUID','uniqueidentifier')),(select Value from IQClient_CustomSettings where Field = 'Multiplier' and _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))))))
					END
					as  SQAD_SHAREVALUE,
					
					CASE WHEN  SQAD_SHAREVALUE = 0 OR SQAD_SHAREVALUE IS NULL THEN
						CASE WHEN CONVERT(DECIMAL(18,2),Avg_Ratings_Pt * 100* (Cast(([IQCore_Clip].EndOffset - [IQCore_Clip].StartOffset + 1) as Decimal(18,2)) /30 ) * (SELECT CONVERT(float,ISNULL((select Value from IQClient_CustomSettings where Field = 'Multiplier' and _ClientGuid = tblXml.c.value('@ClientGUID','uniqueidentifier')),(select Value from IQClient_CustomSettings where Field = 'Multiplier' and _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))))) * 
										CASE WHEN IQ_Station.SQADMARKETID = 997 AND IQ_Nielsen_Averages.DAYPARTID = 6 THEN
											@CppDayPart2Val
										ELSE
											(SELECT CPPVALUE FROM IQ_SQAD WHERE IQ_SQAD.SQADMARKETID = IQ_Station.SQADMARKETID AND IQ_SQAD.DAYPARTID = IQ_Nielsen_Averages.DAYPARTID)
										END) IS NULL THEN
							NULL
						ELSE
							'E'
						END
					ELSE
						'A'
					END AS Nielsen_Result,
					'v3System',
					'v3System'
		from		
				@XmlData.nodes('/list/Element') as tblXml(c)
					INNER JOIN [IQCore_Clip]
						ON  [IQCore_Clip].[Guid] = tblXml.c.value('@ClipID','uniqueidentifier')
						
					left outer join ArchiveClip
						on ArchiveClip.ClipID=tblXml.c.value('@ClipID','uniqueidentifier')
					
					LEFT OUTER JOIN IQ_Station
						ON LTRIM(RTRIM(Substring(tblXml.c.value('@IQ_CC_Key','varchar(28)'),1,Charindex('_', tblXml.c.value('@IQ_CC_Key','varchar(28)'))-1))) = IQ_Station.IQ_Station_ID
					
					LEFT OUTER JOIN  [IQ_NIELSEN_SQAD]
						ON tblXml.c.value('@IQ_CC_Key','varchar(28)') = [IQ_NIELSEN_SQAD].IQ_CC_Key
						AND [IQ_NIELSEN_SQAD].IQ_Start_Point = CASE WHEN [IQCore_Clip].StartOffset = 0 THEN 1 ELSE CEILING([IQCore_Clip].StartOffset /900.0) END
					
					LEFT OUTER JOIN IQ_Nielsen_Averages 
						ON IQ_Nielsen_Averages.IQ_Start_Point = CASE WHEN [IQCore_Clip].StartOffset = 0 THEN 1 ELSE CEILING([IQCore_Clip].StartOffset /900.0) END
						AND [IQ_NIELSEN_SQAD].iq_cc_key is null
						AND Affil_IQ_CC_Key =  CASE WHEN IQ_Station.Dma_Num = '000' THEN IQ_Station.IQ_Station_ID ELSE Station_Affil + '_' + TimeZone END + '_' + SUBSTRING(tblXml.c.value('@IQ_CC_Key','varchar(28)'),CHARINDEX('_',tblXml.c.value('@IQ_CC_Key','varchar(28)')) +1,13)
					
					inner join Customer
						on tblXml.c.value('@CustomerGUID','uniqueidentifier')=Customer.CustomerGUID
		Where
				ArchiveClip.ClipID is null
				
				
		 INSERT INTO IQArchive_Media
			(
				_ArchiveMediaID,
				MediaType,
				SubMediaType,
				Title,
				HighlightingText,
				MediaDate,
				CategoryGUID,
				ClientGUID,
				CustomerGUID,
				IsActive,
				CreatedDate
			)
		SELECT
				ArchiveClip.ArchiveClipKey,
				'TV',
				'TV',
				ArchiveClip.ClipTitle,
				Convert(varchar(max),ArchiveClip.ClosedCaption),
				ArchiveClip.ClipDate,
				ArchiveClip.CategoryGUID,
				ArchiveClip.ClientGUID,
				ArchiveClip.CustomerGUID,
				1,
				ArchiveClip.ClipCreationDate
		from		
				@XmlData.nodes('/list/Element') as tblXml(c)
					inner join ArchiveClip
						on ArchiveClip.ClipID=tblXml.c.value('@ClipID','uniqueidentifier')
					inner join Customer
						on tblXml.c.value('@CustomerGUID','uniqueidentifier')=Customer.CustomerGUID
					left outer join IQArchive_Media 
						on ArchiveClip.ArchiveClipKey = IQArchive_Media._ArchiveMediaID
		where
				IQArchive_Media._ArchiveMediaID	is null	
		 
		commit transaction
	end try
	begin catch
	
		rollback transaction
		
		declare @IQMediaGroupExceptionKey bigint,
				@ExceptionStackTrace varchar(500),
				@ExceptionMessage varchar(500),
				@CreatedBy	varchar(50),
				@ModifiedBy	varchar(50),
				@CreatedDate	datetime,
				@ModifiedDate	datetime,
				@IsActive	bit
				
		
		Select 
				@ExceptionStackTrace=(ERROR_PROCEDURE()+'_'+CONVERT(varchar(50),ERROR_LINE())),
				@ExceptionMessage=convert(varchar(50),ERROR_NUMBER())+'_'+ERROR_MESSAGE(),
				@CreatedBy='usp_ArchiveClip_InsertList',
				@ModifiedBy='usp_ArchiveClip_InsertList',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
				
		
		exec usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@ModifiedBy,@CreatedDate,@ModifiedDate,@IsActive,@IQMediaGroupExceptionKey output
	
	end catch
END
