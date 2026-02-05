import os
import requests
import json


def fetch_and_update_readme():
    # Retrieve the API Key from environment variables
    api_key = os.getenv("GPTBOTS_API_KEY")

    if not api_key:
        print("Error: GPTBOTS_API_KEY is not set in environment variables.")
        exit(1)

    url = "https://api-sg.gptbots.ai/v1/workflow/invoke"
    headers = {"Authorization": f"Bearer {api_key}", "Content-Type": "application/json"}
    payload = {"userId": "github-action", "input": {}}

    try:
        print("Invoking Agent workflow...")
        response = requests.post(url, headers=headers, json=payload)
        response.raise_for_status()

        data = response.json()

        # Check if the workflow succeeded and extract the content
        if data.get("status") == "SUCCEED":
            new_readme_content = data["output"].get("readme_md")

            if new_readme_content:
                # Save the new content to README.md in the root directory
                with open("README.md", "w", encoding="utf-8") as f:
                    f.write(new_readme_content)
                print("README.md has been successfully updated!")
            else:
                print("Error: 'readme_md' not found in the output.")
        else:
            print(f"Error: Workflow failed with status {data.get('status')}")
            exit(1)

    except Exception as e:
        print(f"An error occurred: {e}")
        exit(1)


if __name__ == "__main__":
    fetch_and_update_readme()
