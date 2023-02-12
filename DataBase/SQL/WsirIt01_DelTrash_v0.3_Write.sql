--Declare @SRnumber NVARCHAR(50) = ''

INSERT INTO SmacPC (
	--id,
	  SRnumber
	, SRlink
	, PCname
	, ip
	, UserLogin
	, UserFIO
	, AdminLogin
	, AdminFIO
	, DateAdd
	, Comment
	, IncidentType
	, WorkType
	)
VALUES (
	--NULL,
	  (case @SRnumber when '' then NULL ELSE @SRnumber END) 
	, (case @SRlink when '' then NULL ELSE @SRlink END) 
	, (case @PCname when '' then NULL ELSE @PCname END)
	, (case @ip when '' then NULL ELSE @ip END) 
	, (case @UserLogin when '' then NULL ELSE @UserLogin END)
	, (case @userFIO  when '' then NULL ELSE @userFIO  END) 
	, (case @AdminLogin when '' then NULL ELSE @AdminLogin END)
	, (case @AdminFIO when '' then NULL ELSE @AdminFIO END) 
	, GetDate()
	, (case @Comment when '' then NULL ELSE @Comment END)  
	, (case @IncidentType when '' then NULL ELSE @IncidentType END)
	, (case @WorkType when '' then NULL ELSE @WorkType END)
	);
--select * from SmacPC order by id DESC
--where SRnumber = ''
--order by id DESC