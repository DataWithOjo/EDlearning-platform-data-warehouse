# 📒 Data Catalogue – Gold Layer (Snow Flake Schema)

This document describes the views available in the **Gold Layer** of the data warehouse for the EdTech analytics project. The Gold Layer presents a business-ready, analytics-friendly schema using a **Snowflake Schema** model, with dimensions, facts, and aggregated views derived from the Silver Layer.

---

## 📘 Dimension Views

These views represent the descriptive attributes for analysis.

### `gold.dim_user_registrations`
User registration and profile details.

| Column Name         | Data Type | Description                          |
|---------------------|-----------|--------------------------------------|
| user_id             | INT       | Unique identifier for the user       |
| city                | TEXT      | City of the user                     |
| state               | TEXT      | State of the user                    |
| country             | TEXT      | Country of the user                  |
| highest_degree      | TEXT      | Highest educational qualification    |
| cgpa                | FLOAT     | Cumulative grade point average       |
| gender              | TEXT      | Gender of the user                   |
| date_of_birth       | DATE      | Date of birth                        |
| registration_date   | DATE      | Date of registration                 |

---

### `gold.dim_user_demographics_details`
Extended user demographic information.

| Column Name         | Data Type | Description                          |
|---------------------|-----------|--------------------------------------|
| user_id             | INT       | Unique identifier for the user       |
| city                | TEXT      | City                                 |
| state               | TEXT      | State                                |
| country             | TEXT      | Country                              |
| gender              | TEXT      | Gender                               |
| dob                 | DATE      | Date of birth                        |
| highest_degree      | TEXT      | Degree achieved                      |
| cgpa                | FLOAT     | Grade point average                  |
| registration_date   | DATE      | Date of joining                      |

---

### `gold.dim_lessons`
Metadata of lessons.

| Column Name     | Data Type | Description               |
|------------------|-----------|---------------------------|
| lesson_id        | INT       | Unique lesson identifier  |
| topic_id         | INT       | Associated topic ID       |
| lesson_title     | TEXT      | Title of the lesson       |
| lesson_type      | TEXT      | Type (video, quiz, etc.)  |
| duration_in_sec  | INT       | Duration in seconds       |

---

### `gold.dim_topics`
Metadata of topics.

| Column Name     | Data Type | Description               |
|------------------|-----------|---------------------------|
| topic_id         | INT       | Unique topic ID           |
| course_id        | INT       | Associated course ID      |
| topic_title      | TEXT      | Title of the topic        |

---

### `gold.dim_courses`
Metadata of courses.

| Column Name     | Data Type | Description              |
|------------------|-----------|--------------------------|
| course_id        | INT       | Unique course ID         |
| track_id         | INT       | Associated track ID      |
| course_title     | TEXT      | Course name              |

---

### `gold.dim_tracks`
Metadata of tracks.

| Column Name     | Data Type | Description              |
|------------------|-----------|--------------------------|
| track_id         | INT       | Unique track ID          |
| track_title      | TEXT      | Title of the track       |

---

### `gold.dim_content_structure`
Hierarchical structure joining lessons → topics → courses → tracks.

| Column Name         | Data Type | Description                        |
|----------------------|-----------|------------------------------------|
| lesson_id            | INT       | Lesson ID                          |
| topic_id             | INT       | Topic ID                           |
| course_id            | INT       | Course ID                          |
| lesson_title         | TEXT      | Title of lesson                    |
| lesson_type          | TEXT      | Type of lesson                     |
| duration_in_sec      | INT       | Duration of lesson                 |
| topic_title          | TEXT      | Topic title                        |
| course_title         | TEXT      | Course title                       |
| track_title          | TEXT      | Track title                        |

---

## 📗 Fact Views

These views capture transactional or measurable user interactions.

### `gold.fact_user_lesson_progress`
Tracks user progress in each lesson.

| Column Name                   | Data Type | Description                            |
|-------------------------------|-----------|----------------------------------------|
| id                            | INT       | Record ID                              |
| user_id                       | INT       | User ID                                |
| lesson_id                     | INT       | Lesson ID                              |
| completion_percentage_difference | FLOAT | Change in completion since last record |
| overall_completion_percentage | FLOAT     | Cumulative completion                  |
| activity_recorded_datetime    | DATETIME  | Timestamp of the activity              |

---

### `gold.fact_user_feedback`
Feedback submitted by users on lessons.

| Column Name         | Data Type | Description                        |
|----------------------|-----------|------------------------------------|
| id                   | INT       | Unique feedback record ID          |
| feedback_id          | INT       | Feedback session ID                |
| user_id              | INT       | User ID                            |
| lesson_id            | INT       | Lesson ID                          |
| language             | TEXT      | Language of the feedback           |
| question             | TEXT      | Feedback question type             |
| answer               | TEXT      | Response to the question           |
| creation_datetime    | DATETIME  | Timestamp of feedback              |

---

## 📙 Aggregate Views

These views represent pre-aggregated data for performance-optimized reporting.

### `gold.agg_day_and_lesson_wise_user_activity`
Daily user lesson completion statistics.

| Column Name                | Data Type | Description                       |
|----------------------------|-----------|-----------------------------------|
| user_id                    | INT       | User ID                           |
| lesson_id                  | INT       | Lesson ID                         |
| activity_date              | DATE      | Date of activity                  |
| daily_completion_percentage| FLOAT     | Max completion on that day        |

---

### `gold.agg_user_learning_streaks`
User learning streak analysis (consecutive learning days).

| Column Name         | Data Type | Description                          |
|----------------------|-----------|--------------------------------------|
| user_id              | INT       | User ID                              |
| activity_date        | DATE      | Date of the activity                 |
| streak_group_id      | INT       | Streak group identifier              |
| streak_day_number    | INT       | Day number within the streak         |

---

### `gold.agg_course_wise_user_completion_percentages`
User-level course completion percentages.

| Column Name                 | Data Type | Description                           |
|-----------------------------|-----------|---------------------------------------|
| user_id                     | INT       | User ID                               |
| course_id                   | INT       | Course ID                             |
| course_completion_percentage| DECIMAL   | Completion % of the course            |

---

### `gold.agg_user_feedback_details`
Condensed view of structured feedback by users per lesson.

| Column Name         | Data Type | Description                              |
|----------------------|-----------|------------------------------------------|
| user_id              | INT       | User ID                                  |
| lesson_id            | INT       | Lesson ID                                |
| rating               | TEXT      | Rating given by user                     |
| liked                | TEXT      | What the user liked                      |
| better_to_improve    | TEXT      | Areas for improvement                    |
| other_feedback       | TEXT      | Other comments                           |
| feedback_timestamp   | DATETIME  | Timestamp of feedback                    |

---

## ✅ Summary

The Gold Layer contains:
- **8 Dimension Views** (User, Lessons, Courses, Tracks, and Structures)
- **2 Fact Views** (User progress and feedback)
- **4 Aggregated Views** (Streaks, Course Completion, Daily Progress, Feedback Summary)

These views are clean, consistent, and ready for consumption by BI tools like Power BI, Tableau, or custom dashboards.

---
