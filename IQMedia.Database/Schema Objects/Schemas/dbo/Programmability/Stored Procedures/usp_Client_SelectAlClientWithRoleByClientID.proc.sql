-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
 CREATE PROCEDURE [dbo].[usp_Client_SelectAlClientWithRoleByClientID] 
	
	(
		@ClientID bigint
	)
AS
BEGIN


declare @sql nvarchar(max)
declare @list varchar(max)
declare @selectlist varchar(max)
select @list =  coalesce(@list + ',','') +'[' +  Rolename + ']' from [Role] where IsActive = 'True'
select @selectlist =  coalesce(@selectlist + ',','') +'isnull(' +  Rolename + ',0) as'''+  RoleName+ '''' from [Role] where IsActive = 'True'


set @sql = 'SELECT 
					[ClientKey],
					[ClientName], ' + @selectlist	+ ',
					[IsActive],
					Address1,
					Address2,
					Attention,
					City,
					MasterClient,
					NoOfUser,
					Phone,
					Zip,
					BillFrequencyID,
					BillTypeID,
					IndustryID,
					PricingCodeID,
					StateID,
					CreatedDate,
					CustomHeaderImage,
					playerlogo,
					IsCustomHeader,
					IsActivePlayerLogo,
					cast(isnull(TotalNoOfIQNotification,(SELECT IQClient_CustomSettings.Value FROM IQClient_CustomSettings WHERE _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AND Field =''TotalNoOfIQNotification'')) as tinyint) as ''NoOfIQNotification'',
					cast(isnull(TotalNoOfIQAgent,(SELECT IQClient_CustomSettings.Value FROM IQClient_CustomSettings WHERE _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AND Field =''TotalNoOfIQAgent'')) as tinyint) as ''NoOfIQAgent'',
					cast(isnull(OtherOnlineAdRate,(SELECT IQClient_CustomSettings.Value FROM IQClient_CustomSettings WHERE _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AND Field =''OtherOnlineAdRate'')) as decimal(18,2)) as ''OtherOnlineAdRate'',
					cast(isnull(OnlineNewsAdRate,(SELECT IQClient_CustomSettings.Value FROM IQClient_CustomSettings WHERE _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AND Field =''OnlineNewsAdRate'')) as decimal(18,2)) as ''OnlineNewsAdRate'',
					cast(isnull(CompeteMultiplier,(SELECT IQClient_CustomSettings.Value FROM IQClient_CustomSettings WHERE _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AND Field =''CompeteMultiplier'')) as decimal(18,2)) as ''CompeteMultiplier'',
					cast(isnull(URLPercentRead,(SELECT IQClient_CustomSettings.Value FROM IQClient_CustomSettings WHERE _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AND Field =''URLPercentRead'')) as decimal(18,2)) as ''URLPercentRead''
		
			FROM
			(
				SELECT 
					* 
				FROM
					(
						SELECT     
								Client.ClientName, 
								Client.ClientKey,
								Client.ClientGUID, 		
								Role.RoleName,
								Client.IsActive,
								Client.Address1,
								Client.Address2,
								Client.Attention,
								Client.City,
								Client.MasterClient,
								Client.NoOfUser,
								Client.Phone,
								Client.Zip,
								Client.BillFrequencyID,
								Client.BillTypeID,
								Client.IndustryID,
								Client.PricingCodeID,
								Client.StateID,
								Client.CreatedDate,
								CAST(ClientRole.IsAccess AS INT) AS ''IsAccess'',
								Client.CustomHeaderImage,Client.playerlogo,
								cast(isnull(Client.IsCustomHeader,''False'') as bit) as ''IsCustomHeader'',
								cast(isnull(Client.IsActivePlayerLogo,''False'') as bit) as ''IsActivePlayerLogo''
						FROM         
								 Role 
									INNER JOIN	ClientRole 
										ON dbo.Role.RoleKey = dbo.ClientRole.RoleID 
									RIGHT OUTER JOIN Client
										ON ClientRole.ClientID = Client.ClientKey
						WHERE
								ClientKey !=0 and  
								ClientKey ='+ convert(varchar(4),@ClientID) +'
					) as a 
					pivot
					(
						max([IsAccess])
						FOR [RoleName] IN ('	+ @list +')
					)AS B
						LEFT OUTER JOIN IQClient_CustomSettings
								ON B.ClientGUID = IQClient_CustomSettings._ClientGUID
			) as C
			pivot 
			(
				MAX(Value) FOR [Field] IN([TotalNoOfIQNotification],[TotalNoOfIQAgent],[OtherOnlineAdRate],[CompeteMultiplier],[OnlineNewsAdRate],[URLPercentRead])
			) as D'
	
	print @sql

	Exec sp_executesql @sql
END

