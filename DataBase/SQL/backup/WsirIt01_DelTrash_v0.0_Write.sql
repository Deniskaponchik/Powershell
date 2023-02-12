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
	  'SR06014477'
	, 'https://bpm.tele2.ru/0/Nui/ViewModule.aspx#CardModuleV2/CasePage/edit/cc2559dc-a0c7-41b6-a2bc-021cd0bc27b3'
	, 'WSZR-WEBSHOP-10'
	, Null
	, 'elvira.golubenko'
	, 'elvira.golubenko'
	, 'admin.ws.tirskikh'
	, 'Тирских Денис Алексеевич'
	, GetDate()
	, NULL
	, 'Заканчивается место на диске C:'
	);


--select * from SmacPC