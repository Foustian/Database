USE [IQMediaGroup]
GO

/****** Object:  StoredProcedure [dbo].[usp_DBJob_IQCompeteAll_DemographicAgeValueUpdate]    Script Date: 3/16/2016 2:09:16 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO








CREATE PROCEDURE [dbo].[usp_DBJob_IQCompeteAll_DemographicAgeValueUpdate] 
	(@RowID BIGINT,
	 @NumberOfRecordAffected INT OUTPUT)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

BEGIN TRY 
	
	DECLARE @ConstantNM FLOAT,@ConstantSM FLOAT,@Coef1 FLOAT = 0,@Coef2 FLOAT = 0,@AcademicCoef1 FLOAT,@AcademicCoef2 FLOAT,
			@BlogCoef1 FLOAT,@BlogCoef2 FLOAT,@ClassifiedCoef1 FLOAT,@ClassifiedCoef2 FLOAT,@CommentCoef1 FLOAT,@CommentCoef2 FLOAT,
			@ConsumerCoef1 FLOAT,@ConsumerCoef2 FLOAT,@CorporateCoef1 FLOAT,@CorporateCoef2 FLOAT,@ForumCoef1 FLOAT,@ForumCoef2 FLOAT,
			@GeneralCoef1 FLOAT,@GeneralCoef2 FLOAT,@GovermentCoef1 FLOAT,@GovermentCoef2 FLOAT,@JournalCoef1 FLOAT,@JournalCoef2 FLOAT,
			@LocalCoef1 FLOAT,@LocalCoef2 FLOAT,@MiscCoef1 FLOAT,@MiscCoef2 FLOAT,@NationalCoef1 FLOAT,@NationalCoef2 FLOAT,
			@NewsCoef1 FLOAT,@NewsCoef2 FLOAT,@OrganisationCoef1 FLOAT,@OrganisationCoef2 FLOAT,@PodCastCoef1 FLOAT,@PodCastCoef2 FLOAT,
			@PressCoef1 FLOAT,@PressCoef2 FLOAT,@RestrictedCoef1 FLOAT,@RestrictedCoef2 FLOAT,@SNetworkCoef1 FLOAT,@SNetworkCoef2 FLOAT,
			@SVideoCoef1 FLOAT,@SVideoCoef2 FLOAT,@TradeCoef1 FLOAT,@TradeCoef2 FLOAT,@WikiCoef1 FLOAT,@WikiCoef2 FLOAT,

			@SMBlogCoef1 FLOAT,@SMBlogCoef2 FLOAT,@SMForumCoef1 FLOAT,@SMForumCoef2 FLOAT,

			@Male FLOAT,@Female FLOAT,@Universe FLOAT,
			@c_gender_male FLOAT,@c_gender_female FLOAT,@c_uniq_visitor FLOAT,@c_age_18_24 FLOAT,@c_age_25_34 FLOAT,@c_age_35_44 FLOAT,
			@c_age_45_54 FLOAT,	@c_age_55_64 FLOAT,@c_age_65_plus FLOAT,
			@a_age_18_24 FLOAT,@a_age_25_34 FLOAT,@a_age_35_44 FLOAT,
			@a_age_45_54 FLOAT,	@a_age_55_64 FLOAT,@a_age_65_plus FLOAT,

			@U_M_18_24 FLOAT,@U_M_25_34 FLOAT,@U_M_35_44 FLOAT,@U_M_45_54 FLOAT,@U_M_55_64 FLOAT,@U_M_65_PLUS FLOAT,
			@U_F_18_24 FLOAT,@U_F_25_34 FLOAT,@U_F_35_44 FLOAT,@U_F_45_54 FLOAT,@U_F_55_64 FLOAT,@U_F_65_PLUS FLOAT,
			@A_M_18_24 FLOAT,@A_M_25_34 FLOAT,@A_M_35_44 FLOAT,@A_M_45_54 FLOAT,@A_M_55_64 FLOAT,@A_M_65_PLUS FLOAT,
			@A_F_18_24 FLOAT,@A_F_25_34 FLOAT,@A_F_35_44 FLOAT,@A_F_45_54 FLOAT,@A_F_55_64 FLOAT,@A_F_65_PLUS FLOAT
			
			DECLARE @mediatype VARCHAR(2),@source_category VARCHAR(50)
			DECLARE @RowCount INT = 0
			DECLARE @ID BIGINT

	DECLARE @StopWatch DATETIME,@SPStartTime DATETIME,@SPTrackingID UNIQUEIDENTIFIER, @TimeDiff DECIMAL(18,2),@SPName VARCHAR(100),@QueryDetail VARCHAR(500)    
	
	SET @SPStartTime=GETDATE()
	SET @Stopwatch=GETDATE()
	SET @SPTrackingID = NEWID()
	SET @SPName ='usp_pshell_IQCompeteAll_DemographicAgeValueUpdate'

	SELECT @ConstantNM = VALUE, @ConstantSM= VALUE FROM IQClient_CustomSettings WHERE Field='DefaultCompeteConstant'

	SELECT @AcademicCoef1=SUBSTRING(VALUE,CHARINDEX('Academic',VALUE)+27,5), @AcademicCoef2=SUBSTRING(VALUE,CHARINDEX('Academic',VALUE)+49,5),
	   @BlogCoef1=SUBSTRING(VALUE,CHARINDEX('Blog',VALUE)+23,5), @BlogCoef2=SUBSTRING(VALUE,CHARINDEX('Blog',VALUE)+45,5),
	   @ClassifiedCoef1=SUBSTRING(VALUE,CHARINDEX('Classified',VALUE)+29,5), @ClassifiedCoef2=SUBSTRING(VALUE,CHARINDEX('Classified',VALUE)+51,5),
	   @CommentCoef1=SUBSTRING(VALUE,CHARINDEX('Comment',VALUE)+26,5), @CommentCoef2=SUBSTRING(VALUE,CHARINDEX('Comment',VALUE)+48,5),
	   @ConsumerCoef1=SUBSTRING(VALUE,CHARINDEX('Consumer',VALUE)+27,5),@ConsumerCoef2=SUBSTRING(VALUE,CHARINDEX('Consumer',VALUE)+49,5),
	   @CorporateCoef1=SUBSTRING(VALUE,CHARINDEX('Corporate',VALUE)+28,5), @CorporateCoef2=SUBSTRING(VALUE,CHARINDEX('Corporate',VALUE)+50,5),
	   @ForumCoef1=SUBSTRING(VALUE,CHARINDEX('Forum',VALUE)+24,5), @ForumCoef2=SUBSTRING(VALUE,CHARINDEX('Forum',VALUE)+46,5),
	   @GeneralCoef1=SUBSTRING(VALUE,CHARINDEX('General',VALUE)+26,5), @GeneralCoef2=SUBSTRING(VALUE,CHARINDEX('General',VALUE)+48,5),
	   @GovermentCoef1=SUBSTRING(VALUE,CHARINDEX('Government',VALUE)+29,5), @GovermentCoef2=SUBSTRING(VALUE,CHARINDEX('Government',VALUE)+51,5), 
	   @JournalCoef1=SUBSTRING(VALUE,CHARINDEX('Journal',VALUE)+26,5), @JournalCoef2=SUBSTRING(VALUE,CHARINDEX('Journal',VALUE)+48,5),
	   @LocalCoef1=SUBSTRING(VALUE,CHARINDEX('Local',VALUE)+24,5), @LocalCoef2=SUBSTRING(VALUE,CHARINDEX('Local',VALUE)+46,5),
	   @MiscCoef1=SUBSTRING(VALUE,CHARINDEX('Miscellaneous',VALUE)+32,5), @MiscCoef2=SUBSTRING(VALUE,CHARINDEX('Miscellaneous',VALUE)+54,5), 
	   @NationalCoef1=SUBSTRING(VALUE,CHARINDEX('National',VALUE)+27,5), @NationalCoef2=SUBSTRING(VALUE,CHARINDEX('National',VALUE)+49,5),
	   @NewsCoef1=SUBSTRING(VALUE,CHARINDEX('News',VALUE)+23,5), @NewsCoef2=SUBSTRING(VALUE,CHARINDEX('News',VALUE)+45,5),
	   @OrganisationCoef1=SUBSTRING(VALUE,CHARINDEX('Organisation',VALUE)+31,5), @OrganisationCoef2=SUBSTRING(VALUE,CHARINDEX('Organisation',VALUE)+53,5), 
	   @PodCastCoef1 =SUBSTRING(VALUE,CHARINDEX('Podcast',VALUE)+26,5), @PodCastCoef2=SUBSTRING(VALUE,CHARINDEX('Podcast',VALUE)+48,5),
	   @PressCoef1=SUBSTRING(VALUE,CHARINDEX('Press Wire',VALUE)+29,5), @PressCoef2=SUBSTRING(VALUE,CHARINDEX('Press Wire',VALUE)+51,5),
	   @RestrictedCoef1=SUBSTRING(VALUE,CHARINDEX('Restricted',VALUE)+29,5), @RestrictedCoef2=SUBSTRING(VALUE,CHARINDEX('Restricted',VALUE)+51,5), 
	   @SNetworkCoef1=SUBSTRING(VALUE,CHARINDEX('Social Network',VALUE)+33,5), @SNetworkCoef2=SUBSTRING(VALUE,CHARINDEX('Social Network',VALUE)+55,5),
	   @SVideoCoef1=SUBSTRING(VALUE,CHARINDEX('Social Video',VALUE)+31,5), @SVideoCoef2=SUBSTRING(VALUE,CHARINDEX('Social Video',VALUE)+53,5),
	   @TradeCoef1=SUBSTRING(VALUE,CHARINDEX('Trade',VALUE)+24,5), @TradeCoef2=SUBSTRING(VALUE,CHARINDEX('Trade',VALUE)+46,5),
	   @WikiCoef1=SUBSTRING(VALUE,CHARINDEX('Wiki',VALUE)+23,5),@WikiCoef2=SUBSTRING(VALUE,CHARINDEX('Wiki',VALUE)+45,5)
    FROM IQClient_CustomSettings WITH (NOLOCK) WHERE Field like 'NMCompeteCoeff' 

	SELECT @SMBlogCoef1=SUBSTRING(VALUE,CHARINDEX('Blog',VALUE)+23,5), @SMBlogCoef2=SUBSTRING(VALUE,CHARINDEX('Blog',VALUE)+45,5)
	   FROM IQClient_CustomSettings WITH (NOLOCK) WHERE Field like 'BLCompeteCoeff' 

	SELECT @SMForumCoef1=SUBSTRING(VALUE,CHARINDEX('Forum',VALUE)+24,5), @SMForumCoef2=SUBSTRING(VALUE,CHARINDEX('Forum',VALUE)+46,5)
	   FROM IQClient_CustomSettings WITH (NOLOCK) WHERE Field like 'FOCompeteCoeff' 

    IF @RowID = -1 
	   DECLARE t_cursor CURSOR FOR SELECT
	        ID, c_gender_male,c_gender_female,c_uniq_visitor,c_age_18_24,c_age_25_34,c_age_35_44,c_age_45_54,c_age_55_64,c_age_65_plus,mediatype,source_category
			  FROM IQ_CompeteAll WITH (NOLOCK) WHERE c_uniq_visitor > 0
	ELSE
		DECLARE t_cursor CURSOR FOR SELECT
	        ID, c_gender_male,c_gender_female,c_uniq_visitor,c_age_18_24,c_age_25_34,c_age_35_44,c_age_45_54,c_age_55_64,c_age_65_plus,mediatype,source_category
			  FROM IQ_CompeteAll WITH (NOLOCK) WHERE c_uniq_visitor > 0 AND ID = @RowID

	OPEN t_cursor
	FETCH NEXT FROM t_cursor INTO @ID, @c_gender_male,@c_gender_female,@c_uniq_visitor,@c_age_18_24,@c_age_25_34,@c_age_35_44,@c_age_45_54,@c_age_55_64,
			 @c_age_65_plus,@mediatype,@source_category

       WHILE @@FETCH_STATUS = 0
	     BEGIN

		  SELECT @Universe=@c_uniq_visitor/30.25, @male= @c_gender_male/100, @female=@c_gender_female/100
		  SELECT @a_age_18_24=@c_age_18_24/100, @a_age_25_34=@c_age_25_34/100, @a_age_35_44=@c_age_35_44/100,
		         @a_age_45_54=@c_age_45_54/100, @a_age_55_64=@c_age_55_64/100, @a_age_65_plus=@c_age_65_plus/100
		  SELECT @U_M_18_24=@Universe * @Male * @a_age_18_24, 
				 @U_M_25_34=@Universe * @Male * @a_age_25_34,
				 @U_M_35_44=@Universe * @Male * @a_age_35_44,
				 @U_M_45_54=@Universe * @Male * @a_age_45_54,
				 @U_M_55_64=@Universe * @Male * @a_age_55_64,
				 @U_M_65_plus=@Universe * @Male * @a_age_65_plus,
				 @U_F_18_24=@Universe * @Female * @a_age_18_24, 
				 @U_F_25_34=@Universe * @Female * @a_age_25_34,
				 @U_F_35_44=@Universe * @Female * @a_age_35_44,
				 @U_F_45_54=@Universe * @Female * @a_age_45_54,
				 @U_F_55_64=@Universe * @Female * @a_age_55_64,
				 @U_F_65_plus=@Universe * @Female * @a_age_65_plus

		  IF @mediatype = 'NM'
		    BEGIN
		      IF @source_category='Academic' SELECT 
			                     @A_M_18_24 = @Universe * @Male * @a_age_18_24 * @ConstantNM * @AcademicCoef1 * @AcademicCoef2,
								 @A_M_25_34 = @Universe * @Male * @a_age_25_34 * @ConstantNM * @AcademicCoef1 * @AcademicCoef2,
								 @A_M_35_44 = @Universe * @Male * @a_age_35_44 * @ConstantNM * @AcademicCoef1 * @AcademicCoef2,
								 @A_M_45_54 = @Universe * @Male * @a_age_45_54 * @ConstantNM * @AcademicCoef1 * @AcademicCoef2,
								 @A_M_55_64 = @Universe * @Male * @a_age_55_64 * @ConstantNM * @AcademicCoef1 * @AcademicCoef2,
								 @A_M_65_plus = @Universe * @Male * @a_age_65_plus * @ConstantNM * @AcademicCoef1 * @AcademicCoef2,
								 @A_F_18_24 = @Universe * @Female * @a_age_18_24 * @ConstantNM * @AcademicCoef1 * @AcademicCoef2,
								 @A_F_25_34 = @Universe * @Female * @a_age_25_34 * @ConstantNM * @AcademicCoef1 * @AcademicCoef2,
								 @A_F_35_44 = @Universe * @Female * @a_age_35_44 * @ConstantNM * @AcademicCoef1 * @AcademicCoef2,
								 @A_F_45_54 = @Universe * @Female * @a_age_45_54 * @ConstantNM * @AcademicCoef1 * @AcademicCoef2,
								 @A_F_55_64 = @Universe * @Female * @a_age_55_64 * @ConstantNM * @AcademicCoef1 * @AcademicCoef2,
								 @A_F_65_plus = @Universe * @Female * @a_age_65_plus * @ConstantNM * @AcademicCoef1 * @AcademicCoef2
			  ELSE
			  IF   @source_category= 'Blog'  SELECT 
								 @A_M_18_24 = @Universe * @Male * @a_age_18_24 * @ConstantNM * @BlogCoef1 * @BlogCoef2,
								 @A_M_25_34 = @Universe * @Male * @a_age_25_34 * @ConstantNM * @BlogCoef1 * @BlogCoef2,
								 @A_M_35_44 = @Universe * @Male * @a_age_35_44 * @ConstantNM * @BlogCoef1 * @BlogCoef2,
								 @A_M_45_54 = @Universe * @Male * @a_age_45_54 * @ConstantNM * @BlogCoef1 * @BlogCoef2,
								 @A_M_55_64 = @Universe * @Male * @a_age_55_64 * @ConstantNM * @BlogCoef1 * @BlogCoef2,
								 @A_M_65_plus = @Universe * @Male * @a_age_65_plus * @ConstantNM * @BlogCoef1 * @BlogCoef2,
								 @A_F_18_24 = @Universe * @Female * @a_age_18_24 * @ConstantNM * @BlogCoef1 * @BlogCoef2,
								 @A_F_25_34 = @Universe * @Female * @a_age_25_34 * @ConstantNM * @BlogCoef1 * @BlogCoef2,
								 @A_F_35_44 = @Universe * @Female * @a_age_35_44 * @ConstantNM * @BlogCoef1 * @BlogCoef2,
								 @A_F_45_54 = @Universe * @Female * @a_age_45_54 * @ConstantNM * @BlogCoef1 * @BlogCoef2,
								 @A_F_55_64 = @Universe * @Female * @a_age_55_64 * @ConstantNM * @BlogCoef1 * @BlogCoef2,
								 @A_F_65_plus = @Universe * @Female * @a_age_65_plus * @ConstantNM * @BlogCoef1 * @BlogCoef2
			  ELSE
			  IF @source_category= 'Classified'  SELECT	
								 @A_M_18_24 = @Universe * @Male * @a_age_18_24 * @ConstantNM * @ClassifiedCoef1 * @ClassifiedCoef2,
								 @A_M_25_34 = @Universe * @Male * @a_age_25_34 * @ConstantNM * @ClassifiedCoef1 * @ClassifiedCoef2,
								 @A_M_35_44 = @Universe * @Male * @a_age_35_44 * @ConstantNM * @ClassifiedCoef1 * @ClassifiedCoef2,
								 @A_M_45_54 = @Universe * @Male * @a_age_45_54 * @ConstantNM * @ClassifiedCoef1 * @ClassifiedCoef2,
								 @A_M_55_64 = @Universe * @Male * @a_age_55_64 * @ConstantNM * @ClassifiedCoef1 * @ClassifiedCoef2,
								 @A_M_65_plus = @Universe * @Male * @a_age_65_plus * @ConstantNM * @ClassifiedCoef1 * @ClassifiedCoef2,
								 @A_F_18_24 = @Universe * @Female * @a_age_18_24 * @ConstantNM * @ClassifiedCoef1 * @ClassifiedCoef2,
								 @A_F_25_34 = @Universe * @Female * @a_age_25_34 * @ConstantNM * @ClassifiedCoef1 * @ClassifiedCoef2,
								 @A_F_35_44 = @Universe * @Female * @a_age_35_44 * @ConstantNM * @ClassifiedCoef1 * @ClassifiedCoef2,
								 @A_F_45_54 = @Universe * @Female * @a_age_45_54 * @ConstantNM * @ClassifiedCoef1 * @ClassifiedCoef2,
								 @A_F_55_64 = @Universe * @Female * @a_age_55_64 * @ConstantNM * @ClassifiedCoef1 * @ClassifiedCoef2,
								 @A_F_65_plus = @Universe * @Female * @a_age_65_plus * @ConstantNM * @ClassifiedCoef1 * @ClassifiedCoef2	
		      ELSE
			  IF @source_category= 'Comment'  SELECT
								 @A_M_18_24 = @Universe * @Male * @a_age_18_24 * @ConstantNM * @CommentCoef1 * @CommentCoef2,
								 @A_M_25_34 = @Universe * @Male * @a_age_25_34 * @ConstantNM * @CommentCoef1 * @CommentCoef2,
								 @A_M_35_44 = @Universe * @Male * @a_age_35_44 * @ConstantNM * @CommentCoef1 * @CommentCoef2,
								 @A_M_45_54 = @Universe * @Male * @a_age_45_54 * @ConstantNM * @CommentCoef1 * @CommentCoef2,
								 @A_M_55_64 = @Universe * @Male * @a_age_55_64 * @ConstantNM * @CommentCoef1 * @CommentCoef2,
								 @A_M_65_plus = @Universe * @Male * @a_age_65_plus * @ConstantNM * @CommentCoef1 * @CommentCoef2,
								 @A_F_18_24 = @Universe * @Female * @a_age_18_24 * @ConstantNM * @CommentCoef1 * @CommentCoef2,
								 @A_F_25_34 = @Universe * @Female * @a_age_25_34 * @ConstantNM * @CommentCoef1 * @CommentCoef2,
								 @A_F_35_44 = @Universe * @Female * @a_age_35_44 * @ConstantNM * @CommentCoef1 * @CommentCoef2,
								 @A_F_45_54 = @Universe * @Female * @a_age_45_54 * @ConstantNM * @CommentCoef1 * @CommentCoef2,
								 @A_F_55_64 = @Universe * @Female * @a_age_55_64 * @ConstantNM * @CommentCoef1 * @CommentCoef2,
								 @A_F_65_plus = @Universe * @Female * @a_age_65_plus * @ConstantNM * @CommentCoef1 * @CommentCoef2
			  ELSE
			  IF @source_category= 'Consumer'  SELECT
								 @A_M_18_24 = @Universe * @Male * @a_age_18_24 * @ConstantNM * @ConsumerCoef1 * @ConsumerCoef2,
								 @A_M_25_34 = @Universe * @Male * @a_age_25_34 * @ConstantNM * @ConsumerCoef1 * @ConsumerCoef2,
								 @A_M_35_44 = @Universe * @Male * @a_age_35_44 * @ConstantNM * @ConsumerCoef1 * @ConsumerCoef2,
								 @A_M_45_54 = @Universe * @Male * @a_age_45_54 * @ConstantNM * @ConsumerCoef1 * @ConsumerCoef2,
								 @A_M_55_64 = @Universe * @Male * @a_age_55_64 * @ConstantNM * @ConsumerCoef1 * @ConsumerCoef2,
								 @A_M_65_plus = @Universe * @Male * @a_age_65_plus * @ConstantNM * @ConsumerCoef1 * @ConsumerCoef2,
								 @A_F_18_24 = @Universe * @Female * @a_age_18_24 * @ConstantNM * @ConsumerCoef1 * @ConsumerCoef2,
								 @A_F_25_34 = @Universe * @Female * @a_age_25_34 * @ConstantNM * @ConsumerCoef1 * @ConsumerCoef2,
								 @A_F_35_44 = @Universe * @Female * @a_age_35_44 * @ConstantNM * @ConsumerCoef1 * @ConsumerCoef2,
								 @A_F_45_54 = @Universe * @Female * @a_age_45_54 * @ConstantNM * @ConsumerCoef1 * @ConsumerCoef2,
								 @A_F_55_64 = @Universe * @Female * @a_age_55_64 * @ConstantNM * @ConsumerCoef1 * @ConsumerCoef2,
								 @A_F_65_plus = @Universe * @Female * @a_age_65_plus * @ConstantNM * @ConsumerCoef1 * @ConsumerCoef2
			  ELSE
			  IF @source_category= 'Corporate'  SELECT
								 @A_M_18_24 = @Universe * @Male * @a_age_18_24 * @ConstantNM * @CorporateCoef1 * @CorporateCoef2,
								 @A_M_25_34 = @Universe * @Male * @a_age_25_34 * @ConstantNM * @CorporateCoef1 * @CorporateCoef2,
								 @A_M_35_44 = @Universe * @Male * @a_age_35_44 * @ConstantNM * @CorporateCoef1 * @CorporateCoef2,
								 @A_M_45_54 = @Universe * @Male * @a_age_45_54 * @ConstantNM * @CorporateCoef1 * @CorporateCoef2,
								 @A_M_55_64 = @Universe * @Male * @a_age_55_64 * @ConstantNM * @CorporateCoef1 * @CorporateCoef2,
								 @A_M_65_plus = @Universe * @Male * @a_age_65_plus * @ConstantNM * @CorporateCoef1 * @CorporateCoef2,
								 @A_F_18_24 = @Universe * @Female * @a_age_18_24 * @ConstantNM * @CorporateCoef1 * @CorporateCoef2,
								 @A_F_25_34 = @Universe * @Female * @a_age_25_34 * @ConstantNM * @CorporateCoef1 * @CorporateCoef2,
								 @A_F_35_44 = @Universe * @Female * @a_age_35_44 * @ConstantNM * @CorporateCoef1 * @CorporateCoef2,
								 @A_F_45_54 = @Universe * @Female * @a_age_45_54 * @ConstantNM * @CorporateCoef1 * @CorporateCoef2,
								 @A_F_55_64 = @Universe * @Female * @a_age_55_64 * @ConstantNM * @CorporateCoef1 * @CorporateCoef2,
								 @A_F_65_plus = @Universe * @Female * @a_age_65_plus * @ConstantNM * @CorporateCoef1 * @CorporateCoef2
			  ELSE
			  IF @source_category= 'Forum'  SELECT
								 @A_M_18_24 = @Universe * @Male * @a_age_18_24 * @ConstantNM * @ForumCoef1 * @ForumCoef2,
								 @A_M_25_34 = @Universe * @Male * @a_age_25_34 * @ConstantNM * @ForumCoef1 * @ForumCoef2,
								 @A_M_35_44 = @Universe * @Male * @a_age_35_44 * @ConstantNM * @ForumCoef1 * @ForumCoef2,
								 @A_M_45_54 = @Universe * @Male * @a_age_45_54 * @ConstantNM * @ForumCoef1 * @ForumCoef2,
								 @A_M_55_64 = @Universe * @Male * @a_age_55_64 * @ConstantNM * @ForumCoef1 * @ForumCoef2,
								 @A_M_65_plus = @Universe * @Male * @a_age_65_plus * @ConstantNM * @ForumCoef1 * @ForumCoef2,
								 @A_F_18_24 = @Universe * @Female * @a_age_18_24 * @ConstantNM * @ForumCoef1 * @ForumCoef2,
								 @A_F_25_34 = @Universe * @Female * @a_age_25_34 * @ConstantNM * @ForumCoef1 * @ForumCoef2,
								 @A_F_35_44 = @Universe * @Female * @a_age_35_44 * @ConstantNM * @ForumCoef1 * @ForumCoef2,
								 @A_F_45_54 = @Universe * @Female * @a_age_45_54 * @ConstantNM * @ForumCoef1 * @ForumCoef2,
								 @A_F_55_64 = @Universe * @Female * @a_age_55_64 * @ConstantNM * @ForumCoef1 * @ForumCoef2,
								 @A_F_65_plus = @Universe * @Female * @a_age_65_plus * @ConstantNM * @ForumCoef1 * @ForumCoef2
			  ELSE
			  IF @source_category= 'General'  SELECT
								 @A_M_18_24 = @Universe * @Male * @a_age_18_24 * @ConstantNM * @GeneralCoef1 * @GeneralCoef2,
								 @A_M_25_34 = @Universe * @Male * @a_age_25_34 * @ConstantNM * @GeneralCoef1 * @GeneralCoef2,
								 @A_M_35_44 = @Universe * @Male * @a_age_35_44 * @ConstantNM * @GeneralCoef1 * @GeneralCoef2,
								 @A_M_45_54 = @Universe * @Male * @a_age_45_54 * @ConstantNM * @GeneralCoef1 * @GeneralCoef2,
								 @A_M_55_64 = @Universe * @Male * @a_age_55_64 * @ConstantNM * @GeneralCoef1 * @GeneralCoef2,
								 @A_M_65_plus = @Universe * @Male * @a_age_65_plus * @ConstantNM * @GeneralCoef1 * @GeneralCoef2,
								 @A_F_18_24 = @Universe * @Female * @a_age_18_24 * @ConstantNM * @GeneralCoef1 * @GeneralCoef2,
								 @A_F_25_34 = @Universe * @Female * @a_age_25_34 * @ConstantNM * @GeneralCoef1 * @GeneralCoef2,
								 @A_F_35_44 = @Universe * @Female * @a_age_35_44 * @ConstantNM * @GeneralCoef1 * @GeneralCoef2,
								 @A_F_45_54 = @Universe * @Female * @a_age_45_54 * @ConstantNM * @GeneralCoef1 * @GeneralCoef2,
								 @A_F_55_64 = @Universe * @Female * @a_age_55_64 * @ConstantNM * @GeneralCoef1 * @GeneralCoef2,
								 @A_F_65_plus = @Universe * @Female * @a_age_65_plus * @ConstantNM * @GeneralCoef1 * @GeneralCoef2
			  ELSE
			  IF @source_category= 'Government'  SELECT
								 @A_M_18_24 = @Universe * @Male * @a_age_18_24 * @ConstantNM * @GovermentCoef1 * @GovermentCoef2,
								 @A_M_25_34 = @Universe * @Male * @a_age_25_34 * @ConstantNM * @GovermentCoef1 * @GovermentCoef2,
								 @A_M_35_44 = @Universe * @Male * @a_age_35_44 * @ConstantNM * @GovermentCoef1 * @GovermentCoef2,
								 @A_M_45_54 = @Universe * @Male * @a_age_45_54 * @ConstantNM * @GovermentCoef1 * @GovermentCoef2,
								 @A_M_55_64 = @Universe * @Male * @a_age_55_64 * @ConstantNM * @GovermentCoef1 * @GovermentCoef2,
								 @A_M_65_plus = @Universe * @Male * @a_age_65_plus * @ConstantNM * @GovermentCoef1 * @GovermentCoef2,
								 @A_F_18_24 = @Universe * @Female * @a_age_18_24 * @ConstantNM * @GovermentCoef1 * @GovermentCoef2,
								 @A_F_25_34 = @Universe * @Female * @a_age_25_34 * @ConstantNM * @GovermentCoef1 * @GovermentCoef2,
								 @A_F_35_44 = @Universe * @Female * @a_age_35_44 * @ConstantNM * @GovermentCoef1 * @GovermentCoef2,
								 @A_F_45_54 = @Universe * @Female * @a_age_45_54 * @ConstantNM * @GovermentCoef1 * @GovermentCoef2,
								 @A_F_55_64 = @Universe * @Female * @a_age_55_64 * @ConstantNM * @GovermentCoef1 * @GovermentCoef2,
								 @A_F_65_plus = @Universe * @Female * @a_age_65_plus * @ConstantNM * @GovermentCoef1 * @GovermentCoef2
			  ELSE
			  IF @source_category= 'Journal'  SELECT
								 @A_M_18_24 = @Universe * @Male * @a_age_18_24 * @ConstantNM * @JournalCoef1 * @JournalCoef2,
								 @A_M_25_34 = @Universe * @Male * @a_age_25_34 * @ConstantNM * @JournalCoef1 * @JournalCoef2,
								 @A_M_35_44 = @Universe * @Male * @a_age_35_44 * @ConstantNM * @JournalCoef1 * @JournalCoef2,
								 @A_M_45_54 = @Universe * @Male * @a_age_45_54 * @ConstantNM * @JournalCoef1 * @JournalCoef2,
								 @A_M_55_64 = @Universe * @Male * @a_age_55_64 * @ConstantNM * @JournalCoef1 * @JournalCoef2,
								 @A_M_65_plus = @Universe * @Male * @a_age_65_plus * @ConstantNM * @JournalCoef1 * @JournalCoef2,
								 @A_F_18_24 = @Universe * @Female * @a_age_18_24 * @ConstantNM * @JournalCoef1 * @JournalCoef2,
								 @A_F_25_34 = @Universe * @Female * @a_age_25_34 * @ConstantNM * @JournalCoef1 * @JournalCoef2,
								 @A_F_35_44 = @Universe * @Female * @a_age_35_44 * @ConstantNM * @JournalCoef1 * @JournalCoef2,
								 @A_F_45_54 = @Universe * @Female * @a_age_45_54 * @ConstantNM * @JournalCoef1 * @JournalCoef2,
								 @A_F_55_64 = @Universe * @Female * @a_age_55_64 * @ConstantNM * @JournalCoef1 * @JournalCoef2,
								 @A_F_65_plus = @Universe * @Female * @a_age_65_plus * @ConstantNM * @JournalCoef1 * @JournalCoef2
			  ELSE
			  IF @source_category= 'Local'  SELECT
								 @A_M_18_24 = @Universe * @Male * @a_age_18_24 * @ConstantNM * @LocalCoef1 * @LocalCoef2,
								 @A_M_25_34 = @Universe * @Male * @a_age_25_34 * @ConstantNM * @LocalCoef1 * @LocalCoef2,
								 @A_M_35_44 = @Universe * @Male * @a_age_35_44 * @ConstantNM * @LocalCoef1 * @LocalCoef2,
								 @A_M_45_54 = @Universe * @Male * @a_age_45_54 * @ConstantNM * @LocalCoef1 * @LocalCoef2,
								 @A_M_55_64 = @Universe * @Male * @a_age_55_64 * @ConstantNM * @LocalCoef1 * @LocalCoef2,
								 @A_M_65_plus = @Universe * @Male * @a_age_65_plus * @ConstantNM * @LocalCoef1 * @LocalCoef2,
								 @A_F_18_24 = @Universe * @Female * @a_age_18_24 * @ConstantNM * @LocalCoef1 * @LocalCoef2,
								 @A_F_25_34 = @Universe * @Female * @a_age_25_34 * @ConstantNM * @LocalCoef1 * @LocalCoef2,
								 @A_F_35_44 = @Universe * @Female * @a_age_35_44 * @ConstantNM * @LocalCoef1 * @LocalCoef2,
								 @A_F_45_54 = @Universe * @Female * @a_age_45_54 * @ConstantNM * @LocalCoef1 * @LocalCoef2,
								 @A_F_55_64 = @Universe * @Female * @a_age_55_64 * @ConstantNM * @LocalCoef1 * @LocalCoef2,
								 @A_F_65_plus = @Universe * @Female * @a_age_65_plus * @ConstantNM * @LocalCoef1 * @LocalCoef2
			  ELSE
			  IF @source_category= 'Miscellaneous'  SELECT
								 @A_M_18_24 = @Universe * @Male * @a_age_18_24 * @ConstantNM * @MiscCoef1 * @MiscCoef2,
								 @A_M_25_34 = @Universe * @Male * @a_age_25_34 * @ConstantNM * @MiscCoef1 * @MiscCoef2,
								 @A_M_35_44 = @Universe * @Male * @a_age_35_44 * @ConstantNM * @MiscCoef1 * @MiscCoef2,
								 @A_M_45_54 = @Universe * @Male * @a_age_45_54 * @ConstantNM * @MiscCoef1 * @MiscCoef2,
								 @A_M_55_64 = @Universe * @Male * @a_age_55_64 * @ConstantNM * @MiscCoef1 * @MiscCoef2,
								 @A_M_65_plus = @Universe * @Male * @a_age_65_plus * @ConstantNM * @MiscCoef1 * @MiscCoef2,
								 @A_F_18_24 = @Universe * @Female * @a_age_18_24 * @ConstantNM * @MiscCoef1 * @MiscCoef2,
								 @A_F_25_34 = @Universe * @Female * @a_age_25_34 * @ConstantNM * @MiscCoef1 * @MiscCoef2,
								 @A_F_35_44 = @Universe * @Female * @a_age_35_44 * @ConstantNM * @MiscCoef1 * @MiscCoef2,
								 @A_F_45_54 = @Universe * @Female * @a_age_45_54 * @ConstantNM * @MiscCoef1 * @MiscCoef2,
								 @A_F_55_64 = @Universe * @Female * @a_age_55_64 * @ConstantNM * @MiscCoef1 * @MiscCoef2,
								 @A_F_65_plus = @Universe * @Female * @a_age_65_plus * @ConstantNM * @MiscCoef1 * @MiscCoef2
			  ELSE
			  IF @source_category= 'National'  SELECT
								 @A_M_18_24 = @Universe * @Male * @a_age_18_24 * @ConstantNM * @NationalCoef1 * @NationalCoef2,
								 @A_M_25_34 = @Universe * @Male * @a_age_25_34 * @ConstantNM * @NationalCoef1 * @NationalCoef2,
								 @A_M_35_44 = @Universe * @Male * @a_age_35_44 * @ConstantNM * @NationalCoef1 * @NationalCoef2,
								 @A_M_45_54 = @Universe * @Male * @a_age_45_54 * @ConstantNM * @NationalCoef1 * @NationalCoef2,
								 @A_M_55_64 = @Universe * @Male * @a_age_55_64 * @ConstantNM * @NationalCoef1 * @NationalCoef2,
								 @A_M_65_plus = @Universe * @Male * @a_age_65_plus * @ConstantNM * @NationalCoef1 * @NationalCoef2,
								 @A_F_18_24 = @Universe * @Female * @a_age_18_24 * @ConstantNM * @NationalCoef1 * @NationalCoef2,
								 @A_F_25_34 = @Universe * @Female * @a_age_25_34 * @ConstantNM * @NationalCoef1 * @NationalCoef2,
								 @A_F_35_44 = @Universe * @Female * @a_age_35_44 * @ConstantNM * @NationalCoef1 * @NationalCoef2,
								 @A_F_45_54 = @Universe * @Female * @a_age_45_54 * @ConstantNM * @NationalCoef1 * @NationalCoef2,
								 @A_F_55_64 = @Universe * @Female * @a_age_55_64 * @ConstantNM * @NationalCoef1 * @NationalCoef2,
								 @A_F_65_plus = @Universe * @Female * @a_age_65_plus * @ConstantNM * @NationalCoef1 * @NationalCoef2
			  ELSE
			  IF @source_category= 'News'  SELECT
								 @A_M_18_24 = @Universe * @Male * @a_age_18_24 * @ConstantNM * @NewsCoef1 * @NewsCoef2,
								 @A_M_25_34 = @Universe * @Male * @a_age_25_34 * @ConstantNM * @NewsCoef1 * @NewsCoef2,
								 @A_M_35_44 = @Universe * @Male * @a_age_35_44 * @ConstantNM * @NewsCoef1 * @NewsCoef2,
								 @A_M_45_54 = @Universe * @Male * @a_age_45_54 * @ConstantNM * @NewsCoef1 * @NewsCoef2,
								 @A_M_55_64 = @Universe * @Male * @a_age_55_64 * @ConstantNM * @NewsCoef1 * @NewsCoef2,
								 @A_M_65_plus = @Universe * @Male * @a_age_65_plus * @ConstantNM * @NewsCoef1 * @NewsCoef2,
								 @A_F_18_24 = @Universe * @Female * @a_age_18_24 * @ConstantNM * @NewsCoef1 * @NewsCoef2,
								 @A_F_25_34 = @Universe * @Female * @a_age_25_34 * @ConstantNM * @NewsCoef1 * @NewsCoef2,
								 @A_F_35_44 = @Universe * @Female * @a_age_35_44 * @ConstantNM * @NewsCoef1 * @NewsCoef2,
								 @A_F_45_54 = @Universe * @Female * @a_age_45_54 * @ConstantNM * @NewsCoef1 * @NewsCoef2,
								 @A_F_55_64 = @Universe * @Female * @a_age_55_64 * @ConstantNM * @NewsCoef1 * @NewsCoef2,
								 @A_F_65_plus = @Universe * @Female * @a_age_65_plus * @ConstantNM * @NewsCoef1 * @NewsCoef2
			  ELSE
			  IF @source_category= 'Organisation'  SELECT
								 @A_M_18_24 = @Universe * @Male * @a_age_18_24 * @ConstantNM * @OrganisationCoef1 * @OrganisationCoef2,
								 @A_M_25_34 = @Universe * @Male * @a_age_25_34 * @ConstantNM * @OrganisationCoef1 * @OrganisationCoef2,
								 @A_M_35_44 = @Universe * @Male * @a_age_35_44 * @ConstantNM * @OrganisationCoef1 * @OrganisationCoef2,
								 @A_M_45_54 = @Universe * @Male * @a_age_45_54 * @ConstantNM * @OrganisationCoef1 * @OrganisationCoef2,
								 @A_M_55_64 = @Universe * @Male * @a_age_55_64 * @ConstantNM * @OrganisationCoef1 * @OrganisationCoef2,
								 @A_M_65_plus = @Universe * @Male * @a_age_65_plus * @ConstantNM * @OrganisationCoef1 * @OrganisationCoef2,
								 @A_F_18_24 = @Universe * @Female * @a_age_18_24 * @ConstantNM * @OrganisationCoef1 * @OrganisationCoef2,
								 @A_F_25_34 = @Universe * @Female * @a_age_25_34 * @ConstantNM * @OrganisationCoef1 * @OrganisationCoef2,
								 @A_F_35_44 = @Universe * @Female * @a_age_35_44 * @ConstantNM * @OrganisationCoef1 * @OrganisationCoef2,
								 @A_F_45_54 = @Universe * @Female * @a_age_45_54 * @ConstantNM * @OrganisationCoef1 * @OrganisationCoef2,
								 @A_F_55_64 = @Universe * @Female * @a_age_55_64 * @ConstantNM * @OrganisationCoef1 * @OrganisationCoef2,
								 @A_F_65_plus = @Universe * @Female * @a_age_65_plus * @ConstantNM * @OrganisationCoef1 * @OrganisationCoef2
			  ELSE
			  IF @source_category= 'Podcast'  SELECT
								 @A_M_18_24 = @Universe * @Male * @a_age_18_24 * @ConstantNM * @PodcastCoef1 * @PodcastCoef2,
								 @A_M_25_34 = @Universe * @Male * @a_age_25_34 * @ConstantNM * @PodcastCoef1 * @PodcastCoef2,
								 @A_M_35_44 = @Universe * @Male * @a_age_35_44 * @ConstantNM * @PodcastCoef1 * @PodcastCoef2,
								 @A_M_45_54 = @Universe * @Male * @a_age_45_54 * @ConstantNM * @PodcastCoef1 * @PodcastCoef2,
								 @A_M_55_64 = @Universe * @Male * @a_age_55_64 * @ConstantNM * @PodcastCoef1 * @PodcastCoef2,
								 @A_M_65_plus = @Universe * @Male * @a_age_65_plus * @ConstantNM * @PodcastCoef1 * @PodcastCoef2,
								 @A_F_18_24 = @Universe * @Female * @a_age_18_24 * @ConstantNM * @PodcastCoef1 * @PodcastCoef2,
								 @A_F_25_34 = @Universe * @Female * @a_age_25_34 * @ConstantNM * @PodcastCoef1 * @PodcastCoef2,
								 @A_F_35_44 = @Universe * @Female * @a_age_35_44 * @ConstantNM * @PodcastCoef1 * @PodcastCoef2,
								 @A_F_45_54 = @Universe * @Female * @a_age_45_54 * @ConstantNM * @PodcastCoef1 * @PodcastCoef2,
								 @A_F_55_64 = @Universe * @Female * @a_age_55_64 * @ConstantNM * @PodcastCoef1 * @PodcastCoef2,
								 @A_F_65_plus = @Universe * @Female * @a_age_65_plus * @ConstantNM * @PodcastCoef1 * @PodcastCoef2
			  ELSE
			  IF @source_category= 'Press Wire'  SELECT
								 @A_M_18_24 = @Universe * @Male * @a_age_18_24 * @ConstantNM * @PressCoef1 * @PressCoef2,
								 @A_M_25_34 = @Universe * @Male * @a_age_25_34 * @ConstantNM * @PressCoef1 * @PressCoef2,
								 @A_M_35_44 = @Universe * @Male * @a_age_35_44 * @ConstantNM * @PressCoef1 * @PressCoef2,
								 @A_M_45_54 = @Universe * @Male * @a_age_45_54 * @ConstantNM * @PressCoef1 * @PressCoef2,
								 @A_M_55_64 = @Universe * @Male * @a_age_55_64 * @ConstantNM * @PressCoef1 * @PressCoef2,
								 @A_M_65_plus = @Universe * @Male * @a_age_65_plus * @ConstantNM * @PressCoef1 * @PressCoef2,
								 @A_F_18_24 = @Universe * @Female * @a_age_18_24 * @ConstantNM * @PressCoef1 * @PressCoef2,
								 @A_F_25_34 = @Universe * @Female * @a_age_25_34 * @ConstantNM * @PressCoef1 * @PressCoef2,
								 @A_F_35_44 = @Universe * @Female * @a_age_35_44 * @ConstantNM * @PressCoef1 * @PressCoef2,
								 @A_F_45_54 = @Universe * @Female * @a_age_45_54 * @ConstantNM * @PressCoef1 * @PressCoef2,
								 @A_F_55_64 = @Universe * @Female * @a_age_55_64 * @ConstantNM * @PressCoef1 * @PressCoef2,
								 @A_F_65_plus = @Universe * @Female * @a_age_65_plus * @ConstantNM * @PressCoef1 * @PressCoef2
			  ELSE
			  IF @source_category= 'Restricted'  SELECT
								 @A_M_18_24 = @Universe * @Male * @a_age_18_24 * @ConstantNM * @RestrictedCoef1 * @RestrictedCoef2,
								 @A_M_25_34 = @Universe * @Male * @a_age_25_34 * @ConstantNM * @RestrictedCoef1 * @RestrictedCoef2,
								 @A_M_35_44 = @Universe * @Male * @a_age_35_44 * @ConstantNM * @RestrictedCoef1 * @RestrictedCoef2,
								 @A_M_45_54 = @Universe * @Male * @a_age_45_54 * @ConstantNM * @RestrictedCoef1 * @RestrictedCoef2,
								 @A_M_55_64 = @Universe * @Male * @a_age_55_64 * @ConstantNM * @RestrictedCoef1 * @RestrictedCoef2,
								 @A_M_65_plus = @Universe * @Male * @a_age_65_plus * @ConstantNM * @RestrictedCoef1 * @RestrictedCoef2,
								 @A_F_18_24 = @Universe * @Female * @a_age_18_24 * @ConstantNM * @RestrictedCoef1 * @RestrictedCoef2,
								 @A_F_25_34 = @Universe * @Female * @a_age_25_34 * @ConstantNM * @RestrictedCoef1 * @RestrictedCoef2,
								 @A_F_35_44 = @Universe * @Female * @a_age_35_44 * @ConstantNM * @RestrictedCoef1 * @RestrictedCoef2,
								 @A_F_45_54 = @Universe * @Female * @a_age_45_54 * @ConstantNM * @RestrictedCoef1 * @RestrictedCoef2,
								 @A_F_55_64 = @Universe * @Female * @a_age_55_64 * @ConstantNM * @RestrictedCoef1 * @RestrictedCoef2,
								 @A_F_65_plus = @Universe * @Female * @a_age_65_plus * @ConstantNM * @RestrictedCoef1 * @RestrictedCoef2
			  ELSE
			  IF @source_category= 'Social Network'  SELECT
								 @A_M_18_24 = @Universe * @Male * @a_age_18_24 * @ConstantNM * @SNetworkCoef1 * @SNetworkCoef2,
								 @A_M_25_34 = @Universe * @Male * @a_age_25_34 * @ConstantNM * @SNetworkCoef1 * @SNetworkCoef2,
								 @A_M_35_44 = @Universe * @Male * @a_age_35_44 * @ConstantNM * @SNetworkCoef1 * @SNetworkCoef2,
								 @A_M_45_54 = @Universe * @Male * @a_age_45_54 * @ConstantNM * @SNetworkCoef1 * @SNetworkCoef2,
								 @A_M_55_64 = @Universe * @Male * @a_age_55_64 * @ConstantNM * @SNetworkCoef1 * @SNetworkCoef2,
								 @A_M_65_plus = @Universe * @Male * @a_age_65_plus * @ConstantNM * @SNetworkCoef1 * @SNetworkCoef2,
								 @A_F_18_24 = @Universe * @Female * @a_age_18_24 * @ConstantNM * @SNetworkCoef1 * @SNetworkCoef2,
								 @A_F_25_34 = @Universe * @Female * @a_age_25_34 * @ConstantNM * @SNetworkCoef1 * @SNetworkCoef2,
								 @A_F_35_44 = @Universe * @Female * @a_age_35_44 * @ConstantNM * @SNetworkCoef1 * @SNetworkCoef2,
								 @A_F_45_54 = @Universe * @Female * @a_age_45_54 * @ConstantNM * @SNetworkCoef1 * @SNetworkCoef2,
								 @A_F_55_64 = @Universe * @Female * @a_age_55_64 * @ConstantNM * @SNetworkCoef1 * @SNetworkCoef2,
								 @A_F_65_plus = @Universe * @Female * @a_age_65_plus * @ConstantNM * @SNetworkCoef1 * @SNetworkCoef2
			  ELSE
			  IF @source_category= 'Social Video'  SELECT
								 @A_M_18_24 = @Universe * @Male * @a_age_18_24 * @ConstantNM * @SVideoCoef1 * @SVideoCoef2,
								 @A_M_25_34 = @Universe * @Male * @a_age_25_34 * @ConstantNM * @SVideoCoef1 * @SVideoCoef2,
								 @A_M_35_44 = @Universe * @Male * @a_age_35_44 * @ConstantNM * @SVideoCoef1 * @SVideoCoef2,
								 @A_M_45_54 = @Universe * @Male * @a_age_45_54 * @ConstantNM * @SVideoCoef1 * @SVideoCoef2,
								 @A_M_55_64 = @Universe * @Male * @a_age_55_64 * @ConstantNM * @SVideoCoef1 * @SVideoCoef2,
								 @A_M_65_plus = @Universe * @Male * @a_age_65_plus * @ConstantNM * @SVideoCoef1 * @SVideoCoef2,
								 @A_F_18_24 = @Universe * @Female * @a_age_18_24 * @ConstantNM * @SVideoCoef1 * @SVideoCoef2,
								 @A_F_25_34 = @Universe * @Female * @a_age_25_34 * @ConstantNM * @SVideoCoef1 * @SVideoCoef2,
								 @A_F_35_44 = @Universe * @Female * @a_age_35_44 * @ConstantNM * @SVideoCoef1 * @SVideoCoef2,
								 @A_F_45_54 = @Universe * @Female * @a_age_45_54 * @ConstantNM * @SVideoCoef1 * @SVideoCoef2,
								 @A_F_55_64 = @Universe * @Female * @a_age_55_64 * @ConstantNM * @SVideoCoef1 * @SVideoCoef2,
								 @A_F_65_plus = @Universe * @Female * @a_age_65_plus * @ConstantNM * @SVideoCoef1 * @SVideoCoef2
			  ELSE
			  IF @source_category= 'Trade'  SELECT
								 @A_M_18_24 = @Universe * @Male * @a_age_18_24 * @ConstantNM * @TradeCoef1 * @TradeCoef2,
								 @A_M_25_34 = @Universe * @Male * @a_age_25_34 * @ConstantNM * @TradeCoef1 * @TradeCoef2,
								 @A_M_35_44 = @Universe * @Male * @a_age_35_44 * @ConstantNM * @TradeCoef1 * @TradeCoef2,
								 @A_M_45_54 = @Universe * @Male * @a_age_45_54 * @ConstantNM * @TradeCoef1 * @TradeCoef2,
								 @A_M_55_64 = @Universe * @Male * @a_age_55_64 * @ConstantNM * @TradeCoef1 * @TradeCoef2,
								 @A_M_65_plus = @Universe * @Male * @a_age_65_plus * @ConstantNM * @TradeCoef1 * @TradeCoef2,
								 @A_F_18_24 = @Universe * @Female * @a_age_18_24 * @ConstantNM * @TradeCoef1 * @TradeCoef2,
								 @A_F_25_34 = @Universe * @Female * @a_age_25_34 * @ConstantNM * @TradeCoef1 * @TradeCoef2,
								 @A_F_35_44 = @Universe * @Female * @a_age_35_44 * @ConstantNM * @TradeCoef1 * @TradeCoef2,
								 @A_F_45_54 = @Universe * @Female * @a_age_45_54 * @ConstantNM * @TradeCoef1 * @TradeCoef2,
								 @A_F_55_64 = @Universe * @Female * @a_age_55_64 * @ConstantNM * @TradeCoef1 * @TradeCoef2,
								 @A_F_65_plus = @Universe * @Female * @a_age_65_plus * @ConstantNM * @TradeCoef1 * @TradeCoef2
								 
		      ELSE
			  IF @source_category= 'Wiki'  SELECT	
								 @A_M_18_24 = @Universe * @Male * @a_age_18_24 * @ConstantNM * @WikiCoef1 * @WikiCoef2,
								 @A_M_25_34 = @Universe * @Male * @a_age_25_34 * @ConstantNM * @WikiCoef1 * @WikiCoef2,
								 @A_M_35_44 = @Universe * @Male * @a_age_35_44 * @ConstantNM * @WikiCoef1 * @WikiCoef2,
								 @A_M_45_54 = @Universe * @Male * @a_age_45_54 * @ConstantNM * @WikiCoef1 * @WikiCoef2,
								 @A_M_55_64 = @Universe * @Male * @a_age_55_64 * @ConstantNM * @WikiCoef1 * @WikiCoef2,
								 @A_M_65_plus = @Universe * @Male * @a_age_65_plus * @ConstantNM * @WikiCoef1 * @WikiCoef2,
								 @A_F_18_24 = @Universe * @Female * @a_age_18_24 * @ConstantNM * @WikiCoef1 * @WikiCoef2,
								 @A_F_25_34 = @Universe * @Female * @a_age_25_34 * @ConstantNM * @WikiCoef1 * @WikiCoef2,
								 @A_F_35_44 = @Universe * @Female * @a_age_35_44 * @ConstantNM * @WikiCoef1 * @WikiCoef2,
								 @A_F_45_54 = @Universe * @Female * @a_age_45_54 * @ConstantNM * @WikiCoef1 * @WikiCoef2,
								 @A_F_55_64 = @Universe * @Female * @a_age_55_64 * @ConstantNM * @WikiCoef1 * @WikiCoef2,
								 @A_F_65_plus = @Universe * @Female * @a_age_65_plus * @ConstantNM * @WikiCoef1 * @WikiCoef2
			  ELSE
			  IF @source_category= ''  SELECT		
								 @A_M_18_24 = @Universe * @Male * @a_age_18_24 * @ConstantNM,
								 @A_M_25_34 = @Universe * @Male * @a_age_25_34 * @ConstantNM, 
								 @A_M_35_44 = @Universe * @Male * @a_age_35_44 * @ConstantNM,
								 @A_M_45_54 = @Universe * @Male * @a_age_45_54 * @ConstantNM,
								 @A_M_55_64 = @Universe * @Male * @a_age_55_64 * @ConstantNM,
								 @A_M_65_plus = @Universe * @Male * @a_age_65_plus * @ConstantNM,
								 @A_F_18_24 = @Universe * @Female * @a_age_18_24 * @ConstantNM,
								 @A_F_25_34 = @Universe * @Female * @a_age_25_34 * @ConstantNM,
								 @A_F_35_44 = @Universe * @Female * @a_age_35_44 * @ConstantNM,
								 @A_F_45_54 = @Universe * @Female * @a_age_45_54 * @ConstantNM,
								 @A_F_55_64 = @Universe * @Female * @a_age_55_64 * @ConstantNM,
								 @A_F_65_plus = @Universe * @Female * @a_age_65_plus * @ConstantNM	
			END
		  ELSE
		    IF @mediatype = 'SM'
			   BEGIN
			     IF   @source_category= 'Blog'  SELECT 
								 @A_M_18_24 = @Universe * @Male * @a_age_18_24 * @ConstantSM * @SMBlogCoef1 * @SMBlogCoef2,
								 @A_M_25_34 = @Universe * @Male * @a_age_25_34 * @ConstantSM * @SMBlogCoef1 * @SMBlogCoef2,
								 @A_M_35_44 = @Universe * @Male * @a_age_35_44 * @ConstantSM * @SMBlogCoef1 * @SMBlogCoef2,
								 @A_M_45_54 = @Universe * @Male * @a_age_45_54 * @ConstantSM * @SMBlogCoef1 * @SMBlogCoef2,
								 @A_M_55_64 = @Universe * @Male * @a_age_55_64 * @ConstantSM * @SMBlogCoef1 * @SMBlogCoef2,
								 @A_M_65_plus = @Universe * @Male * @a_age_65_plus * @ConstantSM * @SMBlogCoef1 * @SMBlogCoef2,
								 @A_F_18_24 = @Universe * @Female * @a_age_18_24 * @ConstantSM * @SMBlogCoef1 * @SMBlogCoef2,
								 @A_F_25_34 = @Universe * @Female * @a_age_25_34 * @ConstantSM * @SMBlogCoef1 * @SMBlogCoef2,
								 @A_F_35_44 = @Universe * @Female * @a_age_35_44 * @ConstantSM * @SMBlogCoef1 * @SMBlogCoef2,
								 @A_F_45_54 = @Universe * @Female * @a_age_45_54 * @ConstantSM * @SMBlogCoef1 * @SMBlogCoef2,
								 @A_F_55_64 = @Universe * @Female * @a_age_55_64 * @ConstantSM * @SMBlogCoef1 * @SMBlogCoef2,
								 @A_F_65_plus = @Universe * @Female * @a_age_65_plus * @ConstantSM * @SMBlogCoef1 * @SMBlogCoef2
				 ELSE
				 IF @source_category= 'Forum'  SELECT
								 @A_M_18_24 = @Universe * @Male * @a_age_18_24 * @ConstantSM * @SMForumCoef1 * @SMForumCoef2,
								 @A_M_25_34 = @Universe * @Male * @a_age_25_34 * @ConstantSM * @SMForumCoef1 * @SMForumCoef2,
								 @A_M_35_44 = @Universe * @Male * @a_age_35_44 * @ConstantSM * @SMForumCoef1 * @SMForumCoef2,
								 @A_M_45_54 = @Universe * @Male * @a_age_45_54 * @ConstantSM * @SMForumCoef1 * @SMForumCoef2,
								 @A_M_55_64 = @Universe * @Male * @a_age_55_64 * @ConstantSM * @SMForumCoef1 * @SMForumCoef2,
								 @A_M_65_plus = @Universe * @Male * @a_age_65_plus * @ConstantSM * @SMForumCoef1 * @SMForumCoef2,
								 @A_F_18_24 = @Universe * @Female * @a_age_18_24 * @ConstantSM * @SMForumCoef1 * @SMForumCoef2,
								 @A_F_25_34 = @Universe * @Female * @a_age_25_34 * @ConstantSM * @SMForumCoef1 * @SMForumCoef2,
								 @A_F_35_44 = @Universe * @Female * @a_age_35_44 * @ConstantSM * @SMForumCoef1 * @SMForumCoef2,
								 @A_F_45_54 = @Universe * @Female * @a_age_45_54 * @ConstantSM * @SMForumCoef1 * @SMForumCoef2,
								 @A_F_55_64 = @Universe * @Female * @a_age_55_64 * @ConstantSM * @SMForumCoef1 * @SMForumCoef2,
								 @A_F_65_plus = @Universe * @Female * @a_age_65_plus * @ConstantSM * @SMForumCoef1 * @SMForumCoef2
				 ELSE
				 	  IF @source_category= ''  SELECT		
								 @A_M_18_24 = @Universe * @Male * @a_age_18_24 * @ConstantSM,
								 @A_M_25_34 = @Universe * @Male * @a_age_25_34 * @ConstantSM, 
								 @A_M_35_44 = @Universe * @Male * @a_age_35_44 * @ConstantSM,
								 @A_M_45_54 = @Universe * @Male * @a_age_45_54 * @ConstantSM,
								 @A_M_55_64 = @Universe * @Male * @a_age_55_64 * @ConstantSM,
								 @A_M_65_plus = @Universe * @Male * @a_age_65_plus * @ConstantSM,
								 @A_F_18_24 = @Universe * @Female * @a_age_18_24 * @ConstantSM,
								 @A_F_25_34 = @Universe * @Female * @a_age_25_34 * @ConstantSM,
								 @A_F_35_44 = @Universe * @Female * @a_age_35_44 * @ConstantSM,
								 @A_F_45_54 = @Universe * @Female * @a_age_45_54 * @ConstantSM,
								 @A_F_55_64 = @Universe * @Female * @a_age_55_64 * @ConstantSM,
								 @A_F_65_plus = @Universe * @Female * @a_age_65_plus * @ConstantSM	
			   END
			ELSE
			   IF @mediatype = 'BL'
			     BEGIN
			       IF   @source_category= 'Blog'  SELECT 
								 @A_M_18_24 = @Universe * @Male * @a_age_18_24 * @ConstantSM * @SMBlogCoef1 * @SMBlogCoef2,
								 @A_M_25_34 = @Universe * @Male * @a_age_25_34 * @ConstantSM * @SMBlogCoef1 * @SMBlogCoef2,
								 @A_M_35_44 = @Universe * @Male * @a_age_35_44 * @ConstantSM * @SMBlogCoef1 * @SMBlogCoef2,
								 @A_M_45_54 = @Universe * @Male * @a_age_45_54 * @ConstantSM * @SMBlogCoef1 * @SMBlogCoef2,
								 @A_M_55_64 = @Universe * @Male * @a_age_55_64 * @ConstantSM * @SMBlogCoef1 * @SMBlogCoef2,
								 @A_M_65_plus = @Universe * @Male * @a_age_65_plus * @ConstantSM * @SMBlogCoef1 * @SMBlogCoef2,
								 @A_F_18_24 = @Universe * @Female * @a_age_18_24 * @ConstantSM * @SMBlogCoef1 * @SMBlogCoef2,
								 @A_F_25_34 = @Universe * @Female * @a_age_25_34 * @ConstantSM * @SMBlogCoef1 * @SMBlogCoef2,
								 @A_F_35_44 = @Universe * @Female * @a_age_35_44 * @ConstantSM * @SMBlogCoef1 * @SMBlogCoef2,
								 @A_F_45_54 = @Universe * @Female * @a_age_45_54 * @ConstantSM * @SMBlogCoef1 * @SMBlogCoef2,
								 @A_F_55_64 = @Universe * @Female * @a_age_55_64 * @ConstantSM * @SMBlogCoef1 * @SMBlogCoef2,
								 @A_F_65_plus = @Universe * @Female * @a_age_65_plus * @ConstantSM * @SMBlogCoef1 * @SMBlogCoef2
			     END
			   ELSE
			     IF @mediatype = 'FO'
				    BEGIN
					  IF @source_category= 'Forum'  SELECT
								 @A_M_18_24 = @Universe * @Male * @a_age_18_24 * @ConstantSM * @SMForumCoef1 * @SMForumCoef2,
								 @A_M_25_34 = @Universe * @Male * @a_age_25_34 * @ConstantSM * @SMForumCoef1 * @SMForumCoef2,
								 @A_M_35_44 = @Universe * @Male * @a_age_35_44 * @ConstantSM * @SMForumCoef1 * @SMForumCoef2,
								 @A_M_45_54 = @Universe * @Male * @a_age_45_54 * @ConstantSM * @SMForumCoef1 * @SMForumCoef2,
								 @A_M_55_64 = @Universe * @Male * @a_age_55_64 * @ConstantSM * @SMForumCoef1 * @SMForumCoef2,
								 @A_M_65_plus = @Universe * @Male * @a_age_65_plus * @ConstantSM * @SMForumCoef1 * @SMForumCoef2,
								 @A_F_18_24 = @Universe * @Female * @a_age_18_24 * @ConstantSM * @SMForumCoef1 * @SMForumCoef2,
								 @A_F_25_34 = @Universe * @Female * @a_age_25_34 * @ConstantSM * @SMForumCoef1 * @SMForumCoef2,
								 @A_F_35_44 = @Universe * @Female * @a_age_35_44 * @ConstantSM * @SMForumCoef1 * @SMForumCoef2,
								 @A_F_45_54 = @Universe * @Female * @a_age_45_54 * @ConstantSM * @SMForumCoef1 * @SMForumCoef2,
								 @A_F_55_64 = @Universe * @Female * @a_age_55_64 * @ConstantSM * @SMForumCoef1 * @SMForumCoef2,
								 @A_F_65_plus = @Universe * @Female * @a_age_65_plus * @ConstantSM * @SMForumCoef1 * @SMForumCoef2
					END

		
	      UPDATE IQ_COMPETEALL
		    SET  U_M_18_24 = @U_M_18_24,
				 U_M_25_34 = @U_M_25_34,
				 U_M_35_44 = @U_M_35_44,
				 U_M_45_54 = @U_M_45_54,
				 U_M_55_64 = @U_M_55_64,
				 U_M_65_PLUS = @U_M_65_PLUS,
				 U_F_18_24 = @U_F_18_24,
				 U_F_25_34 = @U_F_25_34,
		         U_F_35_44 = @U_F_35_44,
			     U_F_45_54 = @U_F_45_54,
			     U_F_55_64 = @U_F_55_64,
				 U_F_65_PLUS = @U_F_65_PLUS,
			     A_M_18_24 = @A_M_18_24,
				 A_M_25_34 = @A_M_25_34,
			     A_M_35_44 = @A_M_35_44,
                 A_M_45_54 = @A_M_45_54,
				 A_M_55_64 = @A_M_55_64,
				 A_M_65_PLUS = @A_M_65_PLUS,
			     A_F_18_24 = @A_F_18_24,
			     A_F_25_34 = @A_F_25_34,
	             A_F_35_44 = @A_F_35_44,
	             A_F_45_54 = @A_F_45_54,
			     A_F_55_64 = @A_F_55_64,
				 A_F_65_PLUS = @A_F_65_PLUS
			-- WHERE CURRENT OF t_cursor
			WHERE ID = @ID

		    SET @RowCount = @RowCount + 1

	      FETCH NEXT FROM t_cursor INTO @ID, @c_gender_male,@c_gender_female,@c_uniq_visitor,@c_age_18_24,@c_age_25_34,@c_age_35_44,@c_age_45_54,@c_age_55_64,
			   @c_age_65_plus,@mediatype,@source_category
        END
  
    Close t_cursor
    Deallocate t_cursor

	SET @NumberOfRecordAffected = @RowCount
	SET @QueryDetail ='usp_pshell_IQCompeteAll_DemographicAgeValueUpdate'
	SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
	INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)

	RETURN 0
END TRY
BEGIN CATCH        
   
 
   
   DECLARE @IQMediaGroupExceptionKey BIGINT,
				@ExceptionStackTrace VARCHAR(500),
				@ExceptionMessage VARCHAR(500),
				@CreatedBy	VARCHAR(50),
				@ModifiedBy	VARCHAR(50),
				@CreatedDate	DATETIME,
				@ModifiedDate	DATETIME
			--	@IsActive	BIT
		SELECT 
				@ExceptionStackTrace=(ERROR_PROCEDURE()+'_'+CONVERT(VARCHAR(50),ERROR_LINE())),
				@ExceptionMessage=CONVERT(VARCHAR(50),ERROR_NUMBER())+'_'+ERROR_MESSAGE(),
				@CreatedBy='usp_pshell_IQCompeteAll_DemographicAgeValueUpdate',
				@ModifiedBy='usp_pshell_IQCompeteAll_DemographicAgeValueUpdate',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE()
			--	@IsActive=1
				
        EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT
		Close t_cursor
        Deallocate t_cursor
		SET @NumberOfRecordAffected = 0
		RETURN -1
END CATCH     
      
END








GO


