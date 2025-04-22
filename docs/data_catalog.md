# 📒 Data Catalogue – Gold Layer (Snowflake Schema)

This document describes the views available in the **Gold Layer** of the data warehouse for the EdTech analytics project. The Gold Layer presents a business-ready, analytics-friendly schema using a **Snowflake Schema** model, with dimensions, facts, and aggregated views derived from the Silver Layer.

---

## 📘 Dimension Views

### `gold.dim_user_demographics_details`

An extension of `dim_user_registrations`, this view standardizes user demographic attributes with potentially enriched or de-duplicated values, making it ideal for demographic analysis and segmentation modeling.

**Example Use Case**: Analyze trends in user performance based on age groups or education background.

| Column Name       | Data Type      | Description                        |
|-------------------|----------------|------------------------------------|
| user_id           | NVARCHAR(50)   | Unique identifier for the user     |
| city              | NVARCHAR(50)   | City                               |
| state             | NVARCHAR(50)   | State                              |
| country           | NVARCHAR(50)   | Country                            |
| gender            | NVARCHAR(50)   | Gender                             |
| dob               | DATE           | Date of birth                      |
| highest_degree    | NVARCHAR(50)   | Degree achieved                    |
| cgpa              | DECIMAL(3,1)   | Grade point average                |
| registration_date | DATE           | Date of joining                    |

---

### `gold.dim_lessons`

A lookup table for lessons, storing metadata such as lesson title, type (e.g., video or quiz), and duration.

**Example Use Case**: Identify the most time-consuming or most accessed lessons.

| Column Name     | Data Type      | Description               |
|-----------------|----------------|---------------------------|
| lesson_id       | NVARCHAR(50)   | Unique lesson identifier  |
| topic_id        | NVARCHAR(50)   | Associated topic ID       |
| lesson_title    | NVARCHAR(300)  | Title of the lesson       |
| lesson_type     | NVARCHAR(50)   | Type (video, quiz, etc.)  |
| duration_in_sec | INT            | Duration in seconds       |

---

### `gold.dim_topics`

Topics group lessons into higher-level learning units. This dimension helps analyze performance or engagement across broader subjects.

**Example Use Case**: Compare completion rates across different topics within the same course.

| Column Name   | Data Type      | Description             |
|---------------|----------------|-------------------------|
| topic_id      | NVARCHAR(50)   | Unique topic ID         |
| course_id     | NVARCHAR(50)   | Associated course ID    |
| topic_title   | NVARCHAR(300)  | Title of the topic      |

---

### `gold.dim_courses`

Courses are collections of topics. This view provides metadata like course titles and the associated track.

**Example Use Case**: Evaluate user engagement across different courses or compare course popularity.

| Column Name   | Data Type      | Description             |
|---------------|----------------|-------------------------|
| course_id     | NVARCHAR(50)   | Unique course ID        |
| track_id      | NVARCHAR(50)   | Associated track ID     |
| course_title  | NVARCHAR(300)  | Course name             |

---

### `gold.dim_tracks`

Tracks are high-level learning paths made up of multiple courses. This dimension helps in program-level reporting.

**Example Use Case**: Measure how many learners are enrolled in each learning track and how they perform.

| Column Name   | Data Type      | Description             |
|---------------|----------------|-------------------------|
| track_id      | NVARCHAR(50)   | Unique track ID         |
| track_title   | NVARCHAR(300)  | Title of the track      |

---

### `gold.dim_content_structure`

This is a denormalized view that connects lessons → topics → courses → tracks, combining all structural content hierarchies in one place.

**Example Use Case**: Used extensively in BI tools for building hierarchies, drill-downs, and breadcrumb-style content navigation.

| Column Name     | Data Type      | Description                  |
|------------------|----------------|------------------------------|
| lesson_id        | NVARCHAR(50)   | Lesson ID                    |
| topic_id         | NVARCHAR(50)   | Topic ID                     |
| course_id        | NVARCHAR(50)   | Course ID                    |
| lesson_title     | NVARCHAR(300)  | Title of lesson              |
| lesson_type      | NVARCHAR(50)   | Type of lesson               |
| duration_in_sec  | INT            | Duration of lesson           |
| topic_title      | NVARCHAR(300)  | Topic title                  |
| course_title     | NVARCHAR(300)  | Course title                 |
| track_title      | NVARCHAR(300)  | Track title                  |

---

## 📗 Fact Views

### `gold.fact_user_lesson_progress`

This fact table logs the user’s progress for each lesson. It records both the change in completion since the last entry and the overall percentage.

**Example Use Case**: Track learning velocity or generate progress-over-time reports.

| Column Name                    | Data Type     | Description                            |
|--------------------------------|---------------|----------------------------------------|
| id                             | NVARCHAR(50)  | Record ID                              |
| user_id                        | NVARCHAR(50)  | User ID                                |
| lesson_id                      | NVARCHAR(50)  | Lesson ID                              |
| completion_percentage_difference | INT         | Change in completion since last record |
| overall_completion_percentage  | INT           | Cumulative completion                  |
| activity_recorded_datetime     | DATETIME      | Timestamp of the activity              |

---

### `gold.fact_user_feedback`

Stores structured feedback provided by users about lessons. It supports multilingual content and includes both questions and responses.

**Example Use Case**: Analyze user sentiment or extract improvement areas based on lesson feedback.

| Column Name      | Data Type      | Description                       |
|------------------|----------------|-----------------------------------|
| id               | NVARCHAR(50)   | Unique feedback record ID         |
| feedback_id      | NVARCHAR(50)   | Feedback session ID               |
| user_id          | NVARCHAR(50)   | User ID                           |
| lesson_id        | NVARCHAR(50)   | Lesson ID                         |
| language         | NVARCHAR(50)   | Language of the feedback          |
| question         | NVARCHAR(50)   | Feedback question type            |
| answer           | NVARCHAR(300)  | Response to the question          |
| creation_datetime| DATETIME       | Timestamp of feedback             |

---

## 📙 Aggregate Views

### `gold.agg_day_and_lesson_wise_user_activity`

Captures the highest lesson completion percentage achieved by a user per lesson per day. This helps in understanding daily learning activity.

**Example Use Case**: Identify active vs. dormant users on any given day.

| Column Name                 | Data Type | Description                     |
|-----------------------------|-----------|---------------------------------|
| user_id                     | INT       | User ID                         |
| lesson_id                   | INT       | Lesson ID                       |
| activity_date               | DATE      | Date of activity                |
| daily_completion_percentage | FLOAT     | Max completion on that day      |

---

### `gold.agg_user_learning_streaks`

This view tracks user learning streaks — a count of consecutive days a user was active. It’s useful for gamification or behavioral retention metrics.

**Example Use Case**: Reward users for 7-day or 30-day learning streaks.


| Column Name      | Data Type | Description                    |
|------------------|-----------|--------------------------------|
| user_id          | INT       | User ID                        |
| activity_date    | DATE      | Date of the activity           |
| streak_group_id  | INT       | Streak group identifier        |
| streak_day_number| INT       | Day number within the streak   |

---

### `gold.agg_course_wise_user_completion_percentages`

A high-level summary of how much of a course a user has completed. Helpful for curriculum engagement tracking.

**Example Use Case**: See how many users finished 100% of a course or dropped off midway.

| Column Name                  | Data Type | Description                       |
|------------------------------|-----------|-----------------------------------|
| user_id                      | INT       | User ID                           |
| course_id                    | INT       | Course ID                         |
| course_completion_percentage | DECIMAL   | Completion % of the course        |

---

### `gold.agg_user_feedback_details`

A condensed, normalized summary of structured feedback, including ratings and comments. This simplifies querying user satisfaction metrics.

**Example Use Case**: Identify lessons with low ratings or most frequent suggestions for improvement.

| Column Name       | Data Type     | Description                          |
|-------------------|---------------|--------------------------------------|
| user_id           | INT           | User ID                              |
| lesson_id         | INT           | Lesson ID                            |
| rating            | TEXT          | Rating given by user                 |
| liked             | TEXT          | What the user liked                  |
| better_to_improve | TEXT          | Areas for improvement                |
| other_feedback    | TEXT          | Other comments                       |
| feedback_timestamp| DATETIME      | Timestamp of feedback                |

---

## ✅ Summary

The Gold Layer contains:
- **8 Dimension Views** (User, Lessons, Courses, Tracks, and Structures)
- **2 Fact Views** (User progress and feedback)
- **4 Aggregated Views** (Streaks, Course Completion, Daily Progress, Feedback Summary)

These views are standardized and optimized for analytics tools like Power BI, Tableau, or custom dashboards.
