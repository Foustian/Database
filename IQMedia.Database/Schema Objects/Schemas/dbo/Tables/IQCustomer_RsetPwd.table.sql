CREATE TABLE [dbo].[IQCustomer_RsetPwd]
(
	ID bigint IDENTITY(1,1) NOT NULL, 
	_CustomerGUID uniqueidentifier NOT NULL,
	Token varchar(50) NOT NULL,
	DateExpired datetime2 NOT NULL,
	IsActive bit NOT NULL,
	IsUsed bit NOT NULL
)
