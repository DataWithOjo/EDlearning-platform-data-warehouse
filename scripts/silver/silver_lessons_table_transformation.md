## 🔄 Silver Layer Transformation: Lessons Table

### Overview
The `silver.csv_lessons` table was populated by transforming the `bronze.csv_lessons` data. One key transformation was addressing missing `topic_id` values for `EXAM`-type lessons.

---

### Transformation Logic

1. A placeholder topic_id `'TPC00'` was assigned to lessons where:
   - `topic_id IS NULL`
   - `lesson_type = 'EXAM'`

2. All other fields were transferred with neccessary transformation from the Bronze layer.

---

### Table: silver.lessons

| Column Name     | Type        | Description                                      |
|-----------------|-------------|--------------------------------------------------|
| lesson_id       | NVARCHAR(50) | Unique ID for the lesson                         |
| topic_id        | NVARCHAR(50) | Foreign key to topic (or placeholder 'TPC00')    |
| lesson_title    | NVARCHAR(300)   | Title of the lesson                            |
| lesson_type     | NVARCHAR(50) | Type: VIDEO, PRACTICE, ASSIGNMENT, EXAM          |
| duration_in_sec | INT         | Duration of the lesson in seconds                |
| dwh_create_date | DATETIME2    | Creation Date in the Silver layer             |

---

### Example Rule

```sql
ISNULL(topic_id, 
       CASE WHEN lesson_type = 'EXAM' THEN 'TPC00' ELSE NULL END)
