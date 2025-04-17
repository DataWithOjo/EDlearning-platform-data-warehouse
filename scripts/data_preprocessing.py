import pandas as pd

# Load the CSV file
df = pd.read_csv("lesson_table.csv")

# Strip whitespace from all string columns only
str_cols = df.select_dtypes(include=['object']).columns
df[str_cols] = df[str_cols].apply(lambda x: x.str.strip())

# Convert 'duration_in_sec' to numeric, force errors to NaN
df['duration_in_sec'] = pd.to_numeric(df['duration_in_sec'], errors='coerce')

# Drop rows with invalid or missing duration values
df = df.dropna(subset=['duration_in_sec'])

# Convert duration to int (from float)
df['duration_in_sec'] = df['duration_in_sec'].astype(int)

# Save the cleaned version
df.to_csv("lesson_table_cleaned.csv", index=False, encoding='utf-8')
