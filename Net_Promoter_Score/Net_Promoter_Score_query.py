
import pandas as pd
import numpy as np

from sqlalchemy import create_engine

path_to_db = '/datasets/telecomm_csi.db'
engine = create_engine(f'sqlite:///{path_to_db}', echo = False)


query = """ 
SELECT user_id,
       lt_day,
       (CASE
            WHEN lt_day <= 365 THEN 'новый клиент'
            ELSE 'старый клиент'
         END) AS is_new,
       age,
       (CASE
            WHEN gender_segment = 1 THEN 'женщина'
            WHEN gender_segment = 0 THEN 'мужчина'
        END) AS gender_segment,
        os_name,
        cpe_type_name,
        country,
        city,
        trim(substr(a.title, 3, LENGTH(a.title))) AS age_segment,
        trim(substr(ts.title, 3, LENGTH(ts.title))) AS traffic_segment,
        trim(substr(ls.title, 3, LENGTH(ls.title))) AS lifetime_segment,
        nps_score,
        (CASE
             WHEN nps_score = 9 OR nps_score = 10 THEN 'сторонники'
             WHEN nps_score = 7 OR nps_score = 8 THEN 'нейтралы'
             WHEN nps_score >= 0 OR nps_score <= 6 THEN 'критики'
         END) AS nps_group
FROM user AS u
INNER JOIN location AS l ON u.location_id = l.location_id
INNER JOIN age_segment AS a ON u.age_gr_id = a.age_gr_id
INNER JOIN traffic_segment AS ts ON u.tr_gr_id = ts.tr_gr_id
INNER JOIN lifetime_segment AS ls ON u.lt_gr_id = ls.lt_gr_id
WHERE trim(age_segment) != 'n/a'
"""


df = pd.read_sql(query, engine)
df.head(3)

df.to_csv('telecomm_csi_tableau.csv', index=False)