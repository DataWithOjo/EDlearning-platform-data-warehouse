import pandas as pd
import json

def main():
    # Load the data
    df = pd.read_csv("user_registrations.csv")

    # Corrected JSON objects for rows 38 to 44
    corrected_user_info = {
        38: {"address": {"city": "Bengaluru", "state": "Karnataka", "country": "India"},
             "education_info": {"highest_degree": "Inter", "cgpa": "9.8"},
             "profile": {"gender": "male"}, "dob": "1999-08-31"},
        
        39: {"address": {"city": "Hyderabad", "state": "Telangana", "country": "India"},
             "education_info": {"highest_degree": "Bachelor", "cgpa": "8.6"},
             "profile": {"gender": "female"}, "dob": "1998-07-15"},
        
        40: {"address": {"city": "Vizag", "state": "Andhra Pradesh", "country": "India"},
             "education_info": {"highest_degree": "Diploma", "cgpa": "7.9"},
             "profile": {"gender": "male"}, "dob": "2000-01-21"},
        
        41: {"address": {"city": "Hyderabad", "state": "Telangana", "country": "India"},
             "education_info": {"highest_degree": "Bachelor", "cgpa": "9.0"},
             "profile": {"gender": "male"}, "dob": "1997-11-05"},
        
        42: {"address": {"city": "Hyderabad", "state": "Telangana", "country": "India"},
             "education_info": {"highest_degree": "Master", "cgpa": "8.2"},
             "profile": {"gender": "female"}, "dob": "1996-12-30"},
        
        43: {"address": {"city": "Chittoor", "state": "Telangana", "country": "India"},
             "education_info": {"highest_degree": "Inter", "cgpa": "9.1"},
             "profile": {"gender": "male"}, "dob": "2001-04-18"},
        
        44: {"address": {"city": "Chennai", "state": "Tamil Nadu", "country": "India"},
             "education_info": {"highest_degree": "Bachelor", "cgpa": "8.5"},
             "profile": {"gender": "female"}, "dob": "1995-09-02"},
    }

    # Update user_info field with corrected JSON
    for idx, json_obj in corrected_user_info.items():
        df.at[idx, 'user_info'] = json.dumps(json_obj)

    # Function to safely parse user_info JSON
    def parse_user_info(info):
        try:
            return json.loads(info)
        except:
            return {}

    # Parse JSON
    df['parsed_info'] = df['user_info'].apply(parse_user_info)

    # Extract fields
    df['city'] = df['parsed_info'].apply(lambda x: x.get('address', {}).get('city'))
    df['state'] = df['parsed_info'].apply(lambda x: x.get('address', {}).get('state'))
    df['country'] = df['parsed_info'].apply(lambda x: x.get('address', {}).get('country'))
    df['highest_degree'] = df['parsed_info'].apply(lambda x: x.get('education_info', {}).get('highest_degree'))
    df['cgpa'] = pd.to_numeric(df['parsed_info'].apply(lambda x: x.get('education_info', {}).get('cgpa')), errors='coerce')
    df['gender'] = df['parsed_info'].apply(lambda x: x.get('profile', {}).get('gender'))
    df['dob'] = df['parsed_info'].apply(lambda x: x.get('profile', {}).get('dob') or x.get('dob'))

    # Normalize city name
    df['city'] = df['city'].str.title()

    # Drop unnecessary columns
    df.drop(columns=['parsed_info', 'user_info'], inplace=True)

    # Save the cleaned dataframe
    df.to_csv("user_registrations_cleaned.csv", index=False)
    print("✅ Cleaned data saved to 'user_registrations_cleaned.csv'.")

# Run the function
if __name__ == "__main__":
    main()
