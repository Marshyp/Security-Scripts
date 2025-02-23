import requests
import pandas as pd
import time
import os
import re
from bs4 import BeautifulSoup
from datetime import datetime

# Categories and relevant keywords
CATEGORIES = {
    "Streaming": ["stream", "watch", "live tv", "vod"],
    "AI": ["artificial intelligence", "chatbot", "machine learning"],
    "Piracy": ["torrent", "warez", "crack", "pirate"],
    "Gaming": ["game", "esports", "steam", "playstation", "xbox"],
    "Software Downloads": ["download", "freeware", "cracked software"],
    "File Sharing": ["cloud storage", "upload", "fileshare"]
}

MAX_ROWS = 500  # Including header
OUTPUT_DIR = "Defender/IOCs"
ERROR_LOG_DIR = "Defender/IOCs/error-log"

# Ensure output directories exist
os.makedirs(OUTPUT_DIR, exist_ok=True)
os.makedirs(ERROR_LOG_DIR, exist_ok=True)

SEARCH_ENGINE = "https://www.google.com/search?q="  # Using Google because Bing is rubbish

def fetch_domains_from_search():
    domain_lists = {category: [] for category in CATEGORIES}
    headers = {"User-Agent": "Mozilla/5.0"}

    for category, keywords in CATEGORIES.items():
        query = "+".join(keywords) + "+websites"
        url = SEARCH_ENGINE + query
        
        try:
            response = requests.get(url, headers=headers, timeout=10)
            response.raise_for_status()
            soup = BeautifulSoup(response.text, 'html.parser')
            
            for link in soup.find_all('a', href=True):
                match = re.search(r'https?://([^/]+)/', link['href'])
                if match:
                    domain = match.group(1)
                    domain_lists[category].append(domain)
            
            time.sleep(3)  # Delay to avoid rate limits
        except Exception as e:
            error_msg = f"{datetime.now()}: Error fetching domains for {category} - {str(e)}\n"
            with open(f"{ERROR_LOG_DIR}/error_{datetime.now().strftime('%Y%m%d_%H%M%S')}.log", "w") as f:
                f.write(error_msg)
    
    return domain_lists


def save_to_csv(domain_lists):
    for category, domains in domain_lists.items():
        filename = f"{OUTPUT_DIR}/{category}.csv"
        chunks = [domains[i:i+MAX_ROWS-1] for i in range(0, len(domains), MAX_ROWS-1)]
        
        for i, chunk in enumerate(chunks):
            df = pd.DataFrame(chunk, columns=["IndicatorValue"])
            df.insert(0, "IndicatorType", "DomainName")
            df.insert(2, "ExpirationTime", "")
            df.insert(3, "Action", "Block")
            df.insert(4, "Severity", "")
            df.insert(5, "Title", f"Potentially unsanctioned {category}")
            df.insert(6, "Description", "Blocked by MarshyP")
            df.insert(7, "RecommendedActions", "")
            df.insert(8, "RbacGroups", "")
            df.insert(9, "Category", category)
            df.insert(10, "MitreTechniques", "")
            df.insert(11, "GenerateAlert", "FALSE")
            
            csv_filename = filename if i == 0 else filename.replace(".csv", f"_{i+1}.csv")
            df.to_csv(csv_filename, index=False)


def main():
    domain_lists = fetch_domains_from_search()
    save_to_csv(domain_lists)


if __name__ == "__main__":
    main()
