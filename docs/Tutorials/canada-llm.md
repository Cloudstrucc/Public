# Canada.ca Local LLM Assistant

A specialized assistant that uses Llama 3 8B to index and answer questions about Canadian government policies, procedures, and services.

## Overview

This project crawls and indexes content from the Canada.ca domain, allowing you to:

1. Run local searches on Canadian government content
2. Get answers about policies, programs, and procedures
3. Find relevant source information for follow-up

All processing happens locally on your M4 MacBook Pro, with no data sent to external services.

## System Requirements

- MacBook Pro M4 Pro
- macOS Sonoma or later
- At least 16GB RAM (preferable)
- 15GB+ free storage
- Ollama installed

## Quick Start

```bash
# Install dependencies
brew install ollama
pip install -r requirements.txt

# Start Ollama service
brew services start ollama

# Download Llama 3 8B model
ollama pull llama3:8b

# Run the launcher script
bash canada_assistant.sh
```

## Project Components

- `canada_crawler.py` - Crawls and downloads content from Canada.ca
- `index_web_content.py` - Indexes both web content and local documents
- `canada_query_engine.py` - Custom query engine for Canadian government content
- `canada_app.py` - Web interface and API server for the assistant
- `canada_assistant.sh` - Launcher script for the entire system

## Workflow

1. **Crawl**: The crawler downloads content from Canada.ca and stores it locally
2. **Index**: The indexer processes both web content and your local files
3. **Query**: The query engine connects to Llama 3 8B to answer questions
4. **Interface**: Access the assistant through a web interface or API

## Customizing

### Crawler Settings

Edit `canada_crawler.py` to adjust:
- `MAX_PAGES` - Number of pages to crawl (default: 10000)
- `MAX_WORKERS` - Number of parallel workers (default: 8)
- `RATE_LIMIT` - Time between requests in seconds (default: 0.5)

### Index Settings

Edit `index_web_content.py` to adjust:
- Add additional directories to index
- Change chunking parameters
- Modify embedding settings

### Query Engine

Edit `canada_query_engine.py` to:
- Change the system prompt
- Adjust retrieval parameters
- Modify the number of sources

## Usage Examples

### Web Interface
Navigate to http://localhost:5001 in your browser after starting the server.

### API

```bash
# Query the assistant
curl -X POST -H 'Content-Type: application/json' \
  -d '{"query":"How do I apply for a Canadian passport?"}' \
  http://localhost:5001/query
```

## Tips

- Start with a smaller `MAX_PAGES` value to test the system
- The first query may be slow as the models load
- For better results, be specific in your queries
- Check the sources for official links to follow up

## Troubleshooting

- If the crawler fails, it will save its state and you can resume
- Use the menu in `canada_assistant.sh` to run individual components
- Check if Ollama is running with `brew services list`