CREATE PROCEDURE [dbo].[usp_v5_IQ3rdP_DataTypes_SelectWithCustomer]  
	@CustomerGuid UNIQUEIDENTIFIER
AS  
BEGIN  	
	DECLARE @ClientGuid UNIQUEIDENTIFIER,
			@ClientID BIGINT,
			@CustomerID BIGINT

	SELECT	@ClientGuid = ClientGUID,
			@ClientID = ClientKey,
			@CustomerID = CustomerKey
	FROM	IQMediaGroup.dbo.Customer
	INNER	JOIN IQMediaGroup.dbo.Client
			ON Client.ClientKey = Customer.ClientID
	WHERE	CustomerGUID = @CustomerGuid

	SELECT	ID,
			DataType,
			IQ3rdp_DataTypes.DisplayName,
			YAxisID,
			YAxisName,
			SPName,
			IsAgentSpecific,
			UseHourData,
			UseIDParam,
			SeriesLineType,
			GroupID,
			IQ3rdP_DataTypes.GroupName,
			CASE WHEN IQ3rdP_CustomerDataTypes._DataTypeID IS NULL THEN 0 ELSE 1 END IsSelected,
		    CASE 
			 WHEN ClientRole.ClientRoleKey IS NOT NULL 
					AND CustomerRole.CustomerRoleKey IS NOT NULL 
				THEN 1	
				ELSE 0
			END AS HasAccess
	FROM	IQMediaGroup.dbo.IQ3rdP_DataTypes
	LEFT	JOIN IQMediaGroup.dbo.IQ3rdP_CustomerDataTypes WITH (NOLOCK)
			ON IQ3rdP_CustomerDataTypes._DataTypeID = IQ3rdP_DataTypes.ID
			AND IQ3rdP_CustomerDataTypes._CustomerGuid = @CustomerGuid
	-- Check if user has access to the data type's role
	LEFT	JOIN IQMediaGroup.dbo.Role 
			ON Role.RoleKey = IQ3rdP_DataTypes._RoleKey
			AND Role.IsActive = 1
	LEFT	JOIN IQMediaGroup.dbo.ClientRole
			ON ClientRole.RoleID = Role.RoleKey
			AND ClientRole.ClientID = @ClientID
			AND ClientRole.IsAccess = 1
	LEFT	JOIN IQMediaGroup.dbo.CustomerRole
			ON CustomerRole.RoleID = Role.RoleKey
			AND CustomerRole.CustomerID = @CustomerID
			AND CustomerRole.IsAccess = 1	
	WHERE	_ClientGuid = @ClientGUID
			AND IQ3rdP_DataTypes.IsActive = 1
END