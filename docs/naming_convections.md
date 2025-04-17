# **Naming Conventions**

This document outlines the naming conventions used for schemas, tables, views, columns, and other objects in the data warehouse for the learning platform project.

## **Table of Contents**

1. [General Principles](#general-principles)  
2. [Table Naming Conventions](#table-naming-conventions)  
   - [Bronze Rules](#bronze-rules)  
   - [Silver Rules](#silver-rules)  
   - [Gold Rules](#gold-rules)  
3. [Column Naming Conventions](#column-naming-conventions)  
   - [Surrogate Keys](#surrogate-keys)  
   - [Technical Columns](#technical-columns)  
4. [View Naming Conventions](#view-naming-conventions)  
5. [Stored Procedure Naming Conventions](#stored-procedure-naming-conventions)

---

## **General Principles**

- Use **snake_case**, with all lowercase letters and underscores (`_`) to separate words.  
- Use **English** for all naming.  
- Avoid using **SQL reserved words** as object names.  
- Be **consistent** and **descriptive** in naming to support readability and long-term maintenance.

---

## **Table Naming Conventions**

### **Bronze Rules**

- Use the prefix `bronze_` followed by the original table or file name.
- All raw ingested tables retain their original naming without transformation.
- Example:  
  - `bronze_user_registrations`  
  - `bronze_lesson_table`

### **Silver Rules**

- Use the prefix `silver_` followed by the cleaned or transformed entity name.
- Table names represent cleaned and standardized data.
- Example:  
  - `silver_user_registrations_cleaned`  
  - `silver_lesson_progress_logs`

### **Gold Rules**

- Use business-aligned, analytics-ready names starting with table category.
- Use the following structure:  
  - **`<category>_<entity>`**  
  - `<category>`: One of `dim`, `fact`, `report`  
  - `<entity>`: Descriptive business term  

#### **Examples**:
- `dim_user` → User dimension  
- `dim_lesson` → Lesson dimension  
- `fact_user_lesson_progress` → User lesson activity fact table  
- `report_course_completion_summary` → Aggregated course completion report

#### **Glossary of Category Patterns**

| Pattern     | Meaning                            | Example(s)                                  |
|-------------|------------------------------------|---------------------------------------------|
| `dim_`      | Dimension table (lookup, descriptive) | `dim_course`, `dim_topic`, `dim_date`     |
| `fact_`     | Fact table (metrics/measures)        | `fact_user_lesson_progress`, `fact_feedback` |
| `report_`   | Reporting-ready summary tables       | `report_user_engagement`, `report_daily_streak` |

---

## **Column Naming Conventions**

### **Surrogate Keys**

- Format: **`<entity>_key`**
- Used in dimension tables as primary keys (often auto-incremented).
- Example:  
  - `user_key`, `lesson_key`

### **Technical Columns**

- Prefix: **`dwh_`**  
- Used for metadata columns like audit fields or ETL tracking.
- Examples:
  - `dwh_load_date` → Load timestamp
  - `dwh_update_by` → Last ETL process/user that updated the row

---

## **View Naming Conventions**

- Views should reflect the business or transformation logic clearly.
- Prefix views with layer name and purpose.
- Examples:
  - `silver_vw_parsed_user_info`  
  - `gold_vw_course_completion_percentage`  
  - `gold_vw_user_streaks`

---

## **Stored Procedure Naming Conventions**

- Format: **`load_<layer>_<entity>`**
- Describes ETL procedures used to load a table.

#### **Examples:**
- `load_bronze_user_feedback`  
- `load_silver_lesson_progress_logs`  
- `load_gold_fact_user_lesson_progress`

---

> ✅ Following these conventions ensures clarity, consistency, and easier onboarding for collaborators in the project.

