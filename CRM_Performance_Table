-- This code is sourcing the intl.INTL_CRM_Performance table. Only last 2 weeks of data is overwritten, date prior to this is hardcoded. This means if we want to add a column e.g. or change a logic we need help from data services to overwrite historically or
-- push the data in month by month or quarter by quarter depending on what makes sense data volume-wise
-- 

/*View and table creation*/
/*------------------*/
/*   Create TABLE   */
/*------------------*/
DROP TABLE if exists inprogress_intl.INTL_CRM_Performance;
TRUNCATE TABLE inprogress_intl.INTL_CRM_Performance;

CREATE TABLE inprogress_intl.INTL_CRM_Performance (
   campaign_name VARCHAR(1000)
  ,countrycode VARCHAR(5)
  ,date DATE
  ,campaign_id VARCHAR (50)
  ,member_type VARCHAR(20)
  ,vertical VARCHAR(15)
  ,channel VARCHAR (50)
  ,member_status VARCHAR(20)
  ,sends INT
  ,opens INT
  ,clicks INT
  ,softbounced INT
  ,optouts INT
  ,upgrades INT
  ,day1Upgrades INT
  ,daynUpgrades INT
  ,reUpgrades INT
  ,one_month_upgrades INT
  ,three_month_upgrades INT
  ,six_month_upgrades INT
  ,twelve_month_upgrades INT
  ,upgradeswPromo INT
  ,downgradeReq INT
  ,manualApps INT
  ,profilesCreated INT
  ,profilesReactivated INT
  ,jobsPosted INT
  ,msgBookmark INT
  ,msgPersonal INT
  ,photoMembers INT
  ,photoMembersApproved INT
  ,reviewsSubmitted INT
  ,reviewsApproved INT
  ,verificationsReq INT
  ,verificationsSuccess INT
  ,verificationsVerifiedTotal INT
  ,profilePreviewed INT
  ,visitors INT
);

INSERT INTO inprogress_intl.INTL_CRM_Performance -- There is a process with data services pushing the content of this table into the analytics_prod schema? No longer maintained
-- <query>
  select * from analytics.vw_INTL_CRM_Performance
-- </query>	
;
commit;
GRANT ALL on inprogress_intl.INTL_CRM_Performance to reporting_ro, intl_admin_prod, 'rajasekhar.mandalapu'  WITH GRANT OPTION;

-- 2m41, 27486 rows
select * from analytics.vw_INTL_CRM_Performance;
select year(date), month(date), count(*) from inprogress_intl.INTL_CRM_Performance group by 1,2 order by 1,2;
describe inprogress_intl.INTL_CRM_Performance;

/*------------------*/
/*   Create VIEW    */
/*------------------*/
drop view if exists analytics.vw_INTL_CRM_Performance;

grant SELECT on analytics.vw_INTL_CRM_Performance to reporting_ro, analytics_team, mponnur;

create view analytics.vw_INTL_CRM_Performance as
-- <query>

with iterable_data as (
/*ITERABLE DATA*/
select e.country, date(e.event_datetime) as date, e.campaign_name, e.campaign_id
  ,case when m.role is null then 'Seeker' else initcap(m.role) end as member_type
  ,case 
    when m.vertical = 'homeCare' then 'Housekeeping' 
    when m.vertical IS NULL or m.vertical = '' then 'Childcare' 
    else initcap(lower(m.vertical))
  end as vertical
 ,m.channel 
 ,case when m.memberstatus in ('Basic', 'Lite') then 'basic'
       when m.memberstatus in ('Premium', 'PendingActive', 'InDunning') and m.membertype in ('day 1 premium', 'day 1 premium Provider', 'nth day premium', 
                              'nth day premium Provider', 'CompleteProvider', 'CompleteSeeker', 'Complete Seeker', 'Complete Provider') then 'premium'
       when m.memberstatus = 'Premium' and m.membertype in ('Incomplete', 'Incomplete Seeker') and m.dateFirstPremiumSignup is not null then 'premium'
       when m.memberstatus = 'Premium' and m.membertype in ('Incomplete', 'Incomplete Seeker') and m.dateFirstPremiumSignup is null then 'basic'                         
       when m.memberstatus in ('Premium', 'PendingActive') and m.membertype in ('ReUpgrade', 'ReUpgrade Provider') then 'reupgrade'
    end as member_status
  --Count all for sends (some campaigns are sent multiple times per day)
  ,count(case when e.event_type = 'Sent' then e.member_id end) as sends
  --Distinct counts (Unique member count per dimension)
  ,count(distinct case when e.event_type = 'Open' then e.member_id end) as opens
  ,count(distinct case when e.event_type = 'Click Through' then e.member_id end) as clicks
  ,count(distinct case when e.event_type = 'Soft Bounce' then e.member_id end) as softbounced
  ,count(distinct case when e.event_type = 'Opt Out' then e.member_id end) as optouts
from intl.DW_F_MEMBER_EMAIL_EVENT_DETAIL_INTL e 
  join intl.hive_member m on m.countrycode = e.country and m.memberid = e.member_id and m.IsInternalAccount is not true and m.closedforfraud is not true
where e.event_type in ('Sent','Open','Click Through','Soft Bounce','Opt Out')
  and date(e.event_datetime) < date(current_date) 
  and year(e.event_datetime) >= year(now())-1  
group by 1,2,3,4,5,6,7,8
), 

/*EVENT DATA*/
-- Adding data
-- 3 steps
--   1. Add the event to the nested 'OR' in the where statement, row 199
--   2. (optional) add approval data using a left join
--   3. Add your metric
--   4. Update the full outer join to include the new measure/dimension
event_data as (
select e.countrycode, date(e.datecreated) as date
  -- 'Fix' an incorrect campaign ID. No matching value in the Iterable table for 2299785CTAonTop. Renamed to the correct ID (2299785)
  ,case when concat(e.campaignname, e.adgroupname) = '2299785CTAonTop' then '2299785' else concat(e.campaignname, e.adgroupname) end as campaign_id
  ,case when m.role is null then 'Seeker' else initcap(m.role) end as member_type
  ,case 
    when m.vertical = 'homeCare' then 'Housekeeping' 
    when m.vertical IS NULL or m.vertical = '' then 'Childcare' 
    else initcap(lower(m.vertical))
  end as vertical
 ,m.channel 
 ,case when m.memberstatus in ('Basic', 'Lite') then 'basic'
       when m.memberstatus in ('Premium', 'PendingActive', 'InDunning') and m.membertype in ('day 1 premium', 'day 1 premium Provider', 'nth day premium', 
                              'nth day premium Provider', 'CompleteProvider', 'CompleteSeeker', 'Complete Seeker', 'Complete Provider') then 'premium'
       when m.memberstatus = 'Premium' and m.membertype in ('Incomplete', 'Incomplete Seeker') and m.dateFirstPremiumSignup is not null then 'premium'
       when m.memberstatus = 'Premium' and m.membertype in ('Incomplete', 'Incomplete Seeker') and m.dateFirstPremiumSignup is null then 'basic'                         
       when m.memberstatus in ('Premium', 'PendingActive') and m.membertype in ('ReUpgrade', 'ReUpgrade Provider') then 'reupgrade'
    end as member_status
  ,count(distinct case when e.name = 'Upgrade' then e.memberid end) as upgrades
  ,count(distinct case when e.name = 'Upgrade' and e.itemtype = 'day1Premium' then e.memberid end) as day1Upgrades
  ,count(distinct case when e.name = 'Upgrade' and e.itemtype = 'dayNPremium' then e.memberid end) as daynUpgrades
  ,count(distinct case when e.name = 'Upgrade' and e.itemtype = 'Reupgrade' then e.memberid end) as reUpgrades
  ,count(distinct case when e.name = 'Upgrade' and e.duration = 1 then e.memberid end) as one_month_upgrades
  ,count(distinct case when e.name = 'Upgrade' and e.duration = 3 then e.memberid end) as three_month_upgrades
  ,count(distinct case when e.name = 'Upgrade' and e.duration = 6 then e.memberid end) as six_month_upgrades
  ,count(distinct case when e.name = 'Upgrade' and e.duration = 12 then e.memberid end) as twelve_month_upgrades
  ,count(distinct case when e.name = 'Upgrade' and e.promocode is not null then e.memberid end) as upgradeswPromo
  ,count(distinct case when e.name = 'AccountActionRequest' and e.accountaction = 'Downgrade' then e.memberid end) as downgradeReq
  ,count(distinct case when e.name = 'JobApplication' and e.issystemgenerated is not true then e.jobapplicationid end) as manualApps
  ,count(distinct case when e.name in ('ProfileCreate','ProfileAdd') then e.profileid end) as profilesCreated
  ,count(distinct case when e.name in ('ProfileActivate') then e.profileid end) as profilesReactivated
  ,count(distinct case when e.name in ('JobPost') then e.jobid end) as jobsPosted
  --There is no unique Identifier for messages except for the rkey
  ,count(distinct case when e.name in ('Message') and e.action = 'BOOKMARK' and e.messageType = 'message' then e.rkey end) as msgBookmark
  ,count(distinct case when e.name in ('Message') and e.action is null then e.rkey end) as msgPersonal
  ,count(distinct case when e.name in ('Photo') and e.photoaction in ('Upload') then e.memberid end) as photoMembers 
  ,count(distinct case when img.name in ('Photo') and img.photoaction in ('Approve') then img.memberid end) as photoMembersApproved -- self join because photoaction field is different
  ,count(distinct case when e.name in ('CreateReview') then e.reviewid end) as reviewsSubmitted
  ,count(distinct case when rev.name in ('ReviewApproved') then rev.reviewid end) as reviewsApproved
  --How many people start the email verification process? (Enter their email)
  ,count(distinct case when e.name in ('Verification') and e.action = 'initiate' and e.statusvalue = 'success' then e.memberid end) as verificationsReq
  --Of the above members, what is the success rate?
  ,count(distinct ver.memberid) as verificationsSuccess
  --How many members successfully verify their email?
  ,count(distinct case when e.name in ('Verification') and e.action = 'complete' and e.statusvalue = 'success' then e.memberid end) as verificationsVerifiedTotal
  ,count(distinct case when e.name in ('ProfileView') then e.memberid end) as profilePreviewed
from intl.hive_event e
  join intl.hive_member m on m.countrycode = e.countrycode and m.memberid = e.memberid and m.IsInternalAccount is not true and m.closedforfraud is not true
  --Photo Approval
  left join intl.hive_event img on img.countrycode = e.countrycode and img.memberid = e.memberid and img.datecreated >= e.datecreated
    and img.name in ('Photo') and img.photoaction = 'Approve' and e.photoid = img.photoid
    and img.year >= year(now())-1
    and date(img.datecreated) < date(current_date)
  --Review Approval
  left join intl.hive_event rev on rev.countrycode = e.countrycode and rev.memberid = e.memberid and rev.datecreated >= e.datecreated
    and rev.name in ('ReviewApproved') and e.reviewid = rev.reviewid
    and rev.year >= year(now())-1
    and date(rev.datecreated) < date(current_date)
  --Email verifications
  left join intl.hive_event ver on ver.countrycode = e.countrycode and ver.memberid = e.memberid and ver.datecreated >= e.datecreated 
    and e.name = ver.name and e.action = 'initiate'
    and ver.name in ('Verification') and ver.entitytype = 'Email' and ver.action = 'complete' and ver.statusvalue = 'success'
    and ver.year >= year(now())-1
    and date(ver.datecreated) < date(current_date)
where 
  (
    (e.name = 'Upgrade') or 
    -- Not the Downgrade event. Downgrade event is triggered when a member changes status from Premium to Basic
    (e.name = 'AccountActionRequest' and e.accountaction = 'Downgrade') or
    -- Apps, not auto
    (e.name = 'JobApplication' and e.issystemgenerated is not true) or
    -- Profile related event
    (e.name in ('ProfileCreate','ProfileActivate','ProfileAdd')) or
    (e.name = 'JobPost') or
    -- Message events. Either Bookmark or manual message
    (e.name = 'Message' and ((e.messageType = 'message' and e.action = 'BOOKMARK') or e.action is null)) or
    (e.name = 'Photo' and e.photoaction in ('Upload')) or
    (e.name = 'CreateReview') or 
    -- initiate = start (when you submit your email). complete is when email is successfully verified
    (e.name = 'Verification' and e.entitytype = 'Email' and e.action in ('initiate','complete') and e.statusvalue = 'success') or
    -- Profile preview (provider checks their own profile)
    (e.name = 'ProfileView' and e.memberid = e.providerid) 
  )
  and e.campaign = 'Email' 
  -- Events have to have a campaignid
  and concat(e.campaignname, e.adgroupname) <> '' 
  and e.year >= year(now())-1 
  and date(e.datecreated) < date(current_date)
group by 1,2,3,4,5,6,7
/*END OF EVENT DATA*/
), 

/*VISIT DATA*/
visit_data as (
select 
  v.countrycode, date(v.startdate) as date
  ,case when concat(v.rxcampaignname, v.rxadgroupname) = '2299785CTAonTop' then '2299785' else concat(v.rxcampaignname, v.rxadgroupname) end as campaign_id
  ,case when m.role is null then 'Seeker' else initcap(m.role) end as member_type
  ,case 
    when m.vertical = 'homeCare' then 'Housekeeping' 
    when m.vertical IS NULL or m.vertical = '' then 'Childcare' 
    else initcap(lower(m.vertical))
  end as vertical
 ,m.channel 
 ,case when m.memberstatus in ('Basic', 'Lite') then 'basic'
       when m.memberstatus in ('Premium', 'PendingActive', 'InDunning') and m.membertype in ('day 1 premium', 'day 1 premium Provider', 'nth day premium', 
                              'nth day premium Provider', 'CompleteProvider', 'CompleteSeeker', 'Complete Seeker', 'Complete Provider') then 'premium'
       when m.memberstatus = 'Premium' and m.membertype in ('Incomplete', 'Incomplete Seeker') and m.dateFirstPremiumSignup is not null then 'premium'
       when m.memberstatus = 'Premium' and m.membertype in ('Incomplete', 'Incomplete Seeker') and m.dateFirstPremiumSignup is null then 'basic'                         
       when m.memberstatus in ('Premium', 'PendingActive') and m.membertype in ('ReUpgrade', 'ReUpgrade Provider') then 'reupgrade'
    end as member_status
  ,count(distinct v.visitorid) as visitors
from intl.hive_visit v
  join intl.hive_member m on m.memberid = v.memberid and m.countrycode = v.countrycode and m.IsInternalAccount is not true and m.closedforfraud is not true
where v.memberid is not null
  and v.year >= year(now())-1
  and date(v.startdate) < date(current_date)
  and v.memberid is not null
  and lower(v.rxcampaign) = 'email'
  and concat(v.rxcampaignname, v.rxadgroupname) <> ''
group by 1,2,3,4,5,6,7
/*END OF VISIT DATA*/
)


select 
  e.campaign_name, countrycode, t.date, t.campaign_id, member_type, vertical, channel, member_status  
  ,sends, opens, clicks, softbounced, optouts
  ,upgrades, day1Upgrades, daynUpgrades, reUpgrades, upgradeswPromo, one_month_upgrades, three_month_upgrades, six_month_upgrades, twelve_month_upgrades
  ,downgradeReq, manualApps, profilesCreated, profilesReactivated, jobsPosted
  ,msgBookmark, msgPersonal, photoMembers, photoMembersApproved
  ,reviewsSubmitted, reviewsApproved, verificationsReq, verificationsSuccess, verificationsVerifiedTotal, profilePreviewed, visitors from (
select
  coalesce(e.countrycode, v.countrycode, i.country) as countrycode,
  coalesce(e.date, v.date, i.date) as date,
  coalesce(e.campaign_id, v.campaign_id, i.campaign_id) as campaign_id,
  coalesce(e.member_type, v.member_type, i.member_type) as member_type,
  coalesce(e.vertical, v.vertical, i.vertical) as vertical,
  coalesce(e.channel, v.channel, i.channel) as channel,
  coalesce(e.member_status, v.member_status, i.member_status) as member_status,
  sum(ifnull(i.sends, 0)) as sends,
  sum(ifnull(i.opens, 0)) as opens,
  sum(ifnull(i.clicks, 0)) as clicks,
  sum(ifnull(i.softbounced, 0)) as softbounced,
  sum(ifnull(i.optouts, 0)) as optouts,
  sum(ifnull(e.upgrades, 0)) as upgrades,
  sum(ifnull(e.day1Upgrades, 0)) as day1Upgrades,
  sum(ifnull(e.daynUpgrades, 0)) as daynUpgrades,
  sum(ifnull(e.reUpgrades, 0)) as reUpgrades,

  sum(ifnull(e.one_month_upgrades, 0)) as one_month_upgrades,
  sum(ifnull(e.three_month_upgrades, 0)) as three_month_upgrades,
  sum(ifnull(e.six_month_upgrades, 0)) as six_month_upgrades,
  sum(ifnull(e.twelve_month_upgrades, 0)) as twelve_month_upgrades,  

  sum(ifnull(e.upgradeswPromo, 0)) as upgradeswPromo,
  sum(ifnull(e.downgradeReq, 0)) as downgradeReq,
  sum(ifnull(e.manualApps, 0)) as manualApps,
  sum(ifnull(e.profilesCreated, 0)) as profilesCreated,
  sum(ifnull(e.profilesReactivated, 0)) as profilesReactivated,
  sum(ifnull(e.jobsPosted, 0)) as jobsPosted,
  sum(ifnull(e.msgBookmark, 0)) as msgBookmark,
  sum(ifnull(e.msgPersonal, 0)) as msgPersonal,
  sum(ifnull(e.photoMembers, 0)) as photoMembers,
  sum(ifnull(e.photoMembersApproved, 0)) as photoMembersApproved,
  sum(ifnull(e.reviewsSubmitted, 0)) as reviewsSubmitted,
  sum(ifnull(e.reviewsApproved, 0)) as reviewsApproved,
  sum(ifnull(e.verificationsReq, 0)) as verificationsReq,
  sum(ifnull(e.verificationsSuccess, 0)) as verificationsSuccess,
  sum(ifnull(e.verificationsVerifiedTotal, 0)) as verificationsVerifiedTotal,
  sum(ifnull(e.profilePreviewed, 0)) as profilePreviewed,
  sum(ifnull(v.visitors, 0)) as visitors
from event_data e
  full outer join visit_data v on e.countrycode = v.countrycode and e.date = v.date and e.campaign_id = v.campaign_id
    and e.member_type = v.member_type and e.vertical = v.vertical and e.channel = v.channel and e.member_status = v.member_status
  full outer join iterable_data i on e.countrycode = i.country and e.date = i.date and e.campaign_id = i.campaign_id
    and e.member_type = i.member_type and e.vertical = i.vertical and e.channel = i.channel and e.member_status = i.member_status
group by 1,2,3,4,5,6,7
) t  left join ( -- What was this left join doing again? Only iterable has campaign_name which is why we do this join.
      select distinct country, campaign_name, campaign_id, date(event_datetime) as date
      from intl.DW_F_MEMBER_EMAIL_EVENT_DETAIL_INTL e
      where e.event_type in ('Sent','Open','Click Through','Soft Bounce','Opt Out')
        and year(e.event_datetime) >= year(now())-1 
    ) e on e.country = t.countrycode and e.campaign_id = t.campaign_id and e.date = t.date

-- </query>
;
