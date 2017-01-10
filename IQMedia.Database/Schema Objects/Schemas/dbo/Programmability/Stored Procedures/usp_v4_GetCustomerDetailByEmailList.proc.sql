CREATE PROCEDURE [dbo].[usp_v4_GetCustomerDetailByLoginIDList]
	@LoginIDXML XML
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Select
			FirstName,
			Lastname,
			LoginID
	From
		Customer
		Inner Join @LoginIDXML.nodes('/EmailIDs/EmailID') as ReportXML(ID)
		ON ReportXML.ID.value('.', 'varchar(max)') = customer.LoginID
			
END
