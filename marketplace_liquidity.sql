with seekers as (
select distinct
    date(m.dateMemberSignup) as sign_up_date
    ,case when jp.vertical='homeCare' then 'housekeeping' else jp.vertical end as vertical
    ,case when jp.subvertical is null then jp.vertical else jp.subvertical end as subvertical
    ,m.countrycode
    ,m.latitude
    ,m.longitude
    ,m.postcode
    ,case when m.countrycode='de' and m.town in ('Berlin','Hamburg','München','Köln','Frankfurt am Main','Essen','Dortmund','Stuttgart','Düsseldorf','Bremen') then m.town
         when m.countrycode='uk' and m.town in ('London','Birmingham','Manchester','Glasgow','Newcastle Upon Tyne','Sheffield','Leeds','Bristol','Nottingham','Liverpool') then m.town
         when m.countrycode='ca' and m.town in ('Toronto','Montreal','Vancouver','Calgary','Edmonton','Ottawa','Winnipeg','Quebec','Hamilton','Kitchener') then m.town    
         when m.countrycode='au' and m.town in ('Sydney','Melbourne','Brisbane','Perth','Adelaide','Gold Coast','Newcastle','Canberra','Sunshine Coast','Wollongong') then m.town 
         when m.countrycode='at' and m.town in ('Wien','Graz','Linz','Salzburg','Innsbruck','Klagenfurt','Wels','Dornbirn','Wiener Neustadt','Steyr') then m.town 
         when m.countrycode='ch' and m.town in ('Zürich','Winterthur','Basel','Luzern','Bern','Winterthur','Dietikon','Saint Gallen','Schaffhausen','Biel') then m.town 
     end as 'town'
    ,count(distinct m.memberid) as seeker_basics
    ,count(distinct jp.jobid) as jobs
    ,count(distinct ja.jobapplicationid) as apps
    ,count(distinct case when ja.issystemgenerated='true' then ja.jobapplicationid end) as autoApps
    ,count(distinct case when ja.issystemgenerated is null then ja.jobapplicationid end) as manualApps
    ,count(distinct case when ja.jobapplicationid is null then jp.jobid end) as jobs_no_apps
  
  from intl.hive_member m
    join intl.hive_event jp       on jp.memberid = m.memberid
                                  and jp.countrycode = m.countrycode
                                  and jp.vertical = m.vertical
                                  and jp.name = 'JobPost'
                                  and jp.vertical in ('childCare','homeCare','petCare')
    join intl.JOB j               on j.member_id = jp.memberid
                                  and j.country_code = jp.countrycode
                                  and j.id = jp.jobid
                                  and j.status = 'Open' --- Does this mean the job is still live?
                                  and j.search_status = 'Approved'
    left join intl.hive_event ja  on ja.seekerid = jp.memberid
                                  and ja.countrycode = jp.countrycode
                                  and ja.jobid = jp.jobid
                                  and ja.name='JobApplication'

  where year(m.dateMemberSignup) = year(current_date)
    and lower(m.role) = 'seeker'
    and m.IsInternalAccount = 'false'
    and m.ClosedForFraud = 'false'
    and m.accountstatus = 'Open' 
    and m.countrycode in ('de','at','ch','uk','ca','au')
    and m.town in ('Berlin','Hamburg','München','Köln','Frankfurt am Main','Essen','Dortmund','Stuttgart','Düsseldorf','Bremen','London','Birmingham','Manchester','Glasgow','Newcastle Upon Tyne','Sheffield','Leeds','Bristol','Nottingham','Liverpool','Toronto','Montreal','Vancouver','Calgary','Edmonton','Ottawa','Winnipeg','Quebec','Hamilton','Kitchener','Sydney','Melbourne','Brisbane','Perth','Adelaide','Gold Coast','Newcastle','Canberra','Sunshine Coast','Wollongong','Wien','Graz','Linz','Salzburg','Innsbruck','Klagenfurt','Wels','Dornbirn','Wiener Neustadt','Steyr','Zürich','Winterthur','Basel','Luzern','Bern','Winterthur','Dietikon','Saint Gallen','Schaffhausen','Biel')
  group by 1,2,3,4,5,6,7,8
),

providers as (
select distinct
    date(m.dateMemberSignup) as sign_up_date
    ,case when vp.vertical_id='homeCare' then 'housekeeping' else vp.vertical_id end as vertical
    ,substring(vpa.attribute_key,instr(vpa.attribute_key,'_')+1,length(vpa.attribute_key)-instr(vpa.attribute_key,'_')+1) as subvertical
    ,m.countrycode
    ,m.latitude
    ,m.longitude
    ,m.postcode
    ,case when m.countrycode='de' and m.town in ('Berlin','Hamburg','München','Köln','Frankfurt am Main','Essen','Dortmund','Stuttgart','Düsseldorf','Bremen') then m.town
         when m.countrycode='uk' and m.town in ('London','Birmingham','Manchester','Glasgow','Newcastle Upon Tyne','Sheffield','Leeds','Bristol','Nottingham','Liverpool') then m.town
         when m.countrycode='ca' and m.town in ('Toronto','Montreal','Vancouver','Calgary','Edmonton','Ottawa','Winnipeg','Quebec','Hamilton','Kitchener') then m.town    
         when m.countrycode='au' and m.town in ('Sydney','Melbourne','Brisbane','Perth','Adelaide','Gold Coast','Newcastle','Canberra','Sunshine Coast','Wollongong') then m.town 
         when m.countrycode='at' and m.town in ('Wien','Graz','Linz','Salzburg','Innsbruck','Klagenfurt','Wels','Dornbirn','Wiener Neustadt','Steyr') then m.town 
         when m.countrycode='ch' and m.town in ('Zürich','Winterthur','Basel','Luzern','Bern','Winterthur','Dietikon','Saint Gallen','Schaffhausen','Biel') then m.town 
     end as 'town'
    ,count(distinct m.memberid) as provider_basics
    ,count(distinct vp.id) as profiles
  
  from intl.hive_member m
    join intl.vertical_profile vp on vp.member_id = m.memberid
                                  and vp.country_code = m.countrycode 
                                  and vp.search_status = 'Approved' --- Does this mean the profile is still active?
                                  and vp.vertical_id in ('childCare','homeCare','petCare')
    join intl.vertical_profile_attribute_value vpa on vp.id = vpa.vertical_profile_id
                                                   and vp.country_code = vpa.country_code
                                                   and vpa.attribute_key like '%InterestedIn%'

  where year(m.dateMemberSignup) = year(current_date)
    and lower(m.role) = 'provider'
    and m.IsInternalAccount = 'false'
    and m.ClosedForFraud = 'false'
    and m.accountstatus = 'Open' 
    and datediff(day,m.lastLoginDate,current_date) <= 180
    and m.countrycode in ('de','at','ch','uk','ca','au')
    and m.town in ('Berlin','Hamburg','München','Köln','Frankfurt am Main','Essen','Dortmund','Stuttgart','Düsseldorf','Bremen','London','Birmingham','Manchester','Glasgow','Newcastle Upon Tyne','Sheffield','Leeds','Bristol','Nottingham','Liverpool','Toronto','Montreal','Vancouver','Calgary','Edmonton','Ottawa','Winnipeg','Quebec','Hamilton','Kitchener','Sydney','Melbourne','Brisbane','Perth','Adelaide','Gold Coast','Newcastle','Canberra','Sunshine Coast','Wollongong','Wien','Graz','Linz','Salzburg','Innsbruck','Klagenfurt','Wels','Dornbirn','Wiener Neustadt','Steyr','Zürich','Winterthur','Basel','Luzern','Bern','Winterthur','Dietikon','Saint Gallen','Schaffhausen','Biel')
  group by 1,2,3,4,5,6,7,8
)
  
select s.sign_up_date, INITCAP(s.vertical) as vertical, INITCAP(s.subvertical) as subvertical, upper(s.countrycode) as countrycode, s.town

      ,ifnull(seeker_basics, 0) as seeker_basics
      ,ifnull(s.jobs, 0) as jobs
      ,ifnull(s.apps, 0) as apps
      ,ifnull(s.autoApps, 0) as autoApps
      ,ifnull(s.manualApps, 0) as manualApps
      ,ifnull(s.jobs_no_apps, 0) as jobs_no_apps
      ,ifnull(p.provider_basics, 0) as provider_basics
      ,ifnull(p.profiles, 0) as profiles
      
      ,ifnull(count(distinct case when (6371 
      * acos (cos (radians(s.latitude))
		  * cos(radians(p.latitude))
		  * cos(radians(p.longitude) - radians(s.longitude))
		  + sin(radians(s.latitude))
		  * sin(radians(p.latitude)))
	    ) <= 5 then p.profiles end),0) as profiles_5km 
		        
      ,ifnull(count(distinct case when (6371 
      * acos (cos (radians(s.latitude))
		  * cos(radians(p.latitude))
		  * cos(radians(p.longitude) - radians(s.longitude))
		  + sin(radians(s.latitude))
		  * sin(radians(p.latitude)))
	    ) <= 10 then p.profiles end),0) as profiles_10km 
		    
      ,ifnull(count(distinct case when (6371 
      * acos (cos (radians(s.latitude))
		  * cos(radians(p.latitude))
		  * cos(radians(p.longitude) - radians(s.longitude))
		  + sin(radians(s.latitude))
		  * sin(radians(p.latitude)))
	    ) <= 15 then p.profiles end),0) as profiles_15km
		    
from seekers s
  left join providers p on p.countrycode = s.countrycode and p.vertical = s.vertical and p.subvertical = s.subvertical and p.town = s.town and p.sign_up_date < s.sign_up_date
  
group by 1,2,3,4,5,6,7,8,9,10,11,12,13
