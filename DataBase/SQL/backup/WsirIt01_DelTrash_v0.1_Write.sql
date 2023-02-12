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
	)
VALUES (
	--NULL,
	  @SRnumber --'SR06014477'
	, @SRlink   --'https://bpm.tele2.ru/0/Nui/ViewModule.aspx#CardModuleV2/CasePage/edit/cc2559dc-a0c7-41b6-a2bc-021cd0bc27b3'
	, @PCname   --'WSZR-WEBSHOP-10'
	, @ip       --Null
	, @UserLogin --'elvira.golubenko'
	, @userFIO   --'elvira.golubenko'
	, @AdminLogin --'admin.ws.tirskikh'
	, @AdminFIO   --'Тирских Денис Алексеевич'
	, GetDate()
	, @Comment    --NULL
	, @IncidentType --'Заканчивается место на диске C:'
	);


--select * from SmacPC order by id DESC
--where SRnumber = ''
--order by id DESC