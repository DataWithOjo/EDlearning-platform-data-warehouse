import pandas as pd

def clean_lesson_table(input_path: str, output_path: str):
    """
    Cleans the lesson_table CSV by stripping whitespace and replacing commas in the lesson_title column.

    Args:
        input_path (str): Path to the raw CSV file.
        output_path (str): Path where the cleaned CSV will be saved.
    """

    # Read the CSV file
    df = pd.read_csv(input_path)

    # Strip leading/trailing whitespace from all string cells
    df = df.applymap(lambda x: x.strip() if isinstance(x, str) else x)

    # Replace commas within the 'lesson_title' field with pipes (|)
    df['lesson_title'] = df['lesson_title'].str.replace(',', '|', regex=False)

    # Save the cleaned CSV file
    df.to_csv(output_path, index=False, encoding='utf-8')
    print(f"✅ Cleaned CSV saved to: {output_path}")

# Run the function
if __name__ == "__main__":
    clean_lesson_table("lesson_table.csv", "lesson_table_cleaned.csv")
