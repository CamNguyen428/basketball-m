begin;

create temporary table teams (
       ncaa_id	       	     integer,
       ncaa_name	     text,
       kaggle_id	     integer,
       kaggle_name	     text,
       strength		     float
);

insert into teams
(ncaa_id,ncaa_name,kaggle_id,kaggle_name,strength)
(
select
r.school_id,
r.school_name,
k.kaggle_id,
k.kaggle_name,
sf.strength
from ncaa.rounds r
join ncaa._schedule_factors sf
  on (sf.year,sf.school_id)=(r.year,r.school_id)
join alias.kaggle k
  on (k.ncaa_id)=(r.school_id)
where
r.year=2017
and r.round_id=3
);

copy
(
select
'2017_'||t1.kaggle_id::text||'_'||t2.kaggle_id as id,
t1.strength^10.25/(t1.strength^10.25+t2.strength^10.25) as pred
from teams t1
join teams t2
  on (t1.kaggle_id < t2.kaggle_id)
order by t1.kaggle_id asc, t2.kaggle_id asc
) to '/tmp/entry.csv' csv header;

commit;
