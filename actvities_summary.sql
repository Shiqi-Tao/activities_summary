--cleaning data

select *
from exercises..activities_vivo4

---Standardize Date/Time Format


Select
  convert(date, Date),
  convert(time(0), Date),
  substring(convert(varchar, Date), 12,8),
  convert(time(0), dateadd(second, datediff(second, 0, time),0)) as exercise_duration
  From exercises..activities_vivo4

 ALTER TABLE exercises..activities_vivo4
 Add exercise_date Date,
     exercise_time Date,
     exercise_duration time;

Update exercises..activities_vivo4
SET exercise_date = convert(date, Date),
    exercise_time = substring(convert(varchar, Date), 12,8),
    exercise_duration = convert(time(0), dateadd(second, datediff(second, 0, time),0))

ALTER TABLE exercises..activities_vivo4
 Add exercise_time1 Date;
Update exercises..activities_vivo4
SET exercise_time1 = substring(convert(varchar, Date), 12,8)

Select 
  date,
  exercise_date,
  exercise_time1,
  exercise_duration
From exercises..activities_vivo4

----exercise_time couldn't be displayed correctly when add into new column, will drop the columns
ALTER TABLE exercises..activities_vivo4
drop column exercise_time1, exercise_time

---Check duplicates
Select row_num
From(
Select * ,
      row_number() over (
	  PARTITION BY date,
	               title,
				   exercise_duration
				   order by 
				      date
				   ) row_num
from exercises..activities_vivo4
 ) as sub
where row_num >1

---create a temp table delete 
Select *
Into activities_vivo4_v1 From (
   Select Activity_type, 
          exercise_date,
		  substring(convert(varchar, Date), 12,8) as exercise_time,
		  exercise_duration,
		  distance,
		  calories,
		  avg_hr,
		  max_hr,
		  avg_run_cadence,
		  max_run_cadence,
		  avg_speed,
		  max_speed,
		  min_elevation,
		  max_elevation
   From exercises..activities_vivo4
   ) as temp

Select *
From activities_vivo4_v1
order by exercise_date
		  

---Progess summary

 ---group by activities
Select 
    activity_type,
    count(*) as number_of_activities,
	sum(distance) as total_distance_km,
	round(sum(cast(datediff(s,'00:00:00', exercise_duration) as float))/3600,2) as total_activity_time_hours, 
	sum(calories) as total_calories,
	round(avg(avg_hr),0) as avg_hr_bpm
From activities_vivo4_v1
group by
   activity_type

---group by month

Select 
    activity_type,
	month,
    count(*) as number_of_activities,
	sum(distance) as total_distance_km,
	round(sum(cast(datediff(s,'00:00:00', exercise_duration) as float))/3600,2) as total_activity_time_hours, 
	sum(calories) as total_calories,
	round(avg(avg_hr),0) as avg_hr_bpm	
From
  (
    Select 
	 activity_type,
	 format(exercise_date, 'y') as month,
	 distance,
	 exercise_duration,
	 calories,
	 avg_hr
 From activities_vivo4_v1
 ) as sub
 group by
 month,
 sub.activity_type