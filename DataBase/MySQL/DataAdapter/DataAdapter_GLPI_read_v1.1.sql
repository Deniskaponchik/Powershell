/*VERSION: 0.1*/
/*РЕАЛИЗАЦИЯ: CTE + SELECT */
/*USE glpi_db;*/

with monitors (mui, proizvod, model, serial, DateMod) as (
	select monit.users_id, manuf2.name, monit.name, monit.serial, monit.date_mod
    from glpi_monitors monit
    left join glpi_manufacturers manuf2 on manuf2.id = monit.manufacturers_id
    /*order by monit.date_mod*/
    )

SELECT 
  c.date_mod DateMod,
  c.contact login, c.name PCname
, comptype.name PCtype, manuf1.name PCmanufacturer, model.name PCmodel, c.serial PCserial
, proc.procname Processor
, ( select sum(idm.size) AS size
    from glpi_items_devicememories idm
    where idm.items_id = c.id
    ) RAM
/*, disks.name disk, disks.device, round(disks.totalsize/1048576,0) total, round(disks.freesize/1048576,0) free*/
, diskC.device DiskC, diskC.name DiskCmodel, diskC.total DiskCtotal, diskC.free DiskCfree
, diskD.device DiskD, diskD.name DiskDmodel, diskD.total DiskDtotal, diskD.free DiskDfree

/*, monitor1.proizvod1, monitor1.serial1*/
, (select proizvod from monitors where mui = c.users_id order by monitors.DateMod DESC LIMIT 1) MonManuf1
, (select model from monitors where mui = c.users_id order by monitors.DateMod DESC LIMIT 1) MonModel1
, (select serial from monitors where mui = c.users_id order by monitors.DateMod DESC LIMIT 1) MonSerial1
, (select proizvod from monitors where mui = c.users_id order by monitors.DateMod DESC LIMIT 1,1) MonManuf2
, (select model from monitors where mui = c.users_id order by monitors.DateMod DESC LIMIT 1,1) MonModel2
, (select serial from monitors where mui = c.users_id order by monitors.DateMod DESC LIMIT 1,1) MonSerial2
, (select proizvod from monitors where mui = c.users_id order by monitors.DateMod DESC LIMIT 2,1) MonManuf3
, (select model from monitors where mui = c.users_id order by monitors.DateMod DESC LIMIT 2,1) MonModel3
, (select serial from monitors where mui = c.users_id order by monitors.DateMod DESC LIMIT 2,1) MonSerial3

, os.Osname, os.OSversion

FROM glpi_db.glpi_computers c
LEFT JOIN glpi_computertypes comptype ON comptype.id = c.computertypes_id
LEFT JOIN glpi_computermodels model ON model.id = c.computermodels_id
left join glpi_manufacturers manuf1 on manuf1.id = c.id

left join (
	select idp.items_id idpii, dp.designation PROCname
    from glpi_items_deviceprocessors idp
    left join glpi_deviceprocessors dp on dp.id = idp.deviceprocessors_id
    ) proc on proc.idpii = c.id

/*left join glpi_items_disks diskD on disks.items_id = c.id*/
left join (
	select items_id, device, name, round(totalsize/1048576,0) total, round(freesize/1048576,0) free
    from glpi_items_disks disk1
    where device = 'C:'
    ) diskC on diskC.items_id = c.id
left join (
	select items_id, device, name, round(totalsize/1048576,0) total, round(freesize/1048576,0) free
    from glpi_items_disks disk2
    where device = 'D:'
    ) diskD on diskD.items_id = c.id

/*left join monitors monitor1 on monitor1.mui = c.users_id*/
/*left join glpi_manufacturers manuf2 ON manuf2.id = (
    select mon1.manufacturers_id
    from glpi_monitors mon1
    where mon1.users_id = c.users_id
    Limit 1    )*/
/*LEFT JOIN LATERAL (
	select monit.users_id mui, manuf.name proizvod1, monit.name serial1
    from glpi_monitors monit
    left join glpi_manufacturers dmanuf2 on manuf2.id = monit.manufacturers_id
    where monit.users_id = c.users_id
    LIMIT 1
    ) monitor1 ON 1=1  --TRUE    */

left join (
	select ios.items_id iosii, os1.name OSname, osv.name OSversion
    from glpi_items_operatingsystems ios
    left join glpi_operatingsystems  os1 on os1.id = ios.operatingsystems_id
    left join glpi_operatingsystemversions osv on osv.id = ios.operatingsystemversions_id
    ) os on os.iosii = c.id

where 
/*c.name = 'wsir-it-03'*/
/*c.contact = 'Vladimir.Inchin'*/
  c.contact = @login
  
  ORDER by c.date_mod DESC