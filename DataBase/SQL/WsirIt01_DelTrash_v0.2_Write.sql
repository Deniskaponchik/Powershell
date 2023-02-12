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
	  (case @SRnumber when '' then NULL ELSE @SRnumber END)     --'SR06014477'
	, (case @SRlink when '' then NULL ELSE @SRlink END)         --@SRlink
	, (case @PCname when '' then NULL ELSE @PCname END)         --@PCname   --'WSZR-WEBSHOP-10'
	, (case @ip when '' then NULL ELSE @ip END)                 --@ip  --Null
	, (case @UserLogin when '' then NULL ELSE @UserLogin END)   --@UserLogin --'elvira.golubenko'
	, (case @userFIO  when '' then NULL ELSE @userFIO  END)     --@userFIO   --'elvira.golubenko'
	, (case @AdminLogin when '' then NULL ELSE @AdminLogin END) --@AdminLogin --'admin.ws.tirskikh'
	, (case @AdminFIO when '' then NULL ELSE @AdminFIO END)     --@AdminFIO   --'Тирских Денис Алексеевич'
	, GetDate()
	, (case @Comment when '' then NULL ELSE @Comment END)       --@Comment    --NULL
	, (case @IncidentType when '' then NULL ELSE @IncidentType END) --@IncidentType --'Заканчивается место на диске C:'
	, (case @WorkType when '' then NULL ELSE @WorkType END)
	);
--select * from SmacPC order by id DESC
--where SRnumber = ''
--order by id DESC