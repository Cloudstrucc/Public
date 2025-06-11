# Building a Spotlight-like Personal Assistant with Llama 3 8B

This guide will walk you through creating a personal assistant that:
- Uses Llama 3 8B for local inference
- Indexes and understands your file system
- Appears as a floating search bar like Spotlight
- Answers questions about your content

## System Requirements
- MacBook Pro M4 Pro
- macOS Sonoma or later
- At least 16GB RAM (preferable)
- 10GB+ free storage

## Step 1: Set Up the Model Environment

First, we'll install Ollama using Homebrew to run Llama 3 8B locally:

```bash
# Install Ollama using Homebrew
brew install ollama

# Start Ollama as a service
brew services start ollama

# Pull Llama 3 8B model
ollama pull llama3:8b
```

## Step 2: Create the Document Processing Pipeline

We'll use LlamaIndex for document indexing and retrieval:

```bash
# Create a project directory
mkdir ~/llm-assistant
cd ~/llm-assistant

# Create a virtual environment
python -m venv venv
source venv/bin/activate

# Install required packages
pip install llama-index llama-index-llms-ollama llama-index-embeddings-huggingface
pip install pypdf docx2txt pptx pillow
pip install flask flask-cors
```

## Step 3: Build the Indexing Script

Create a file called `index_files.py`:

```python
import os
import shutil
from llama_index import VectorStoreIndex, SimpleDirectoryReader
from llama_index.embeddings.huggingface import HuggingFaceEmbedding
from llama_index.storage.storage_context import StorageContext
from llama_index.vector_stores import SimpleVectorStore
from llama_index.node_parser import SimpleNodeParser

# Define directories to index
dirs_to_index = [
    "~/Documents",
    "~/Desktop",
    # Add more directories as needed
]

# Expanded file types
file_extensions = [
    ".txt", ".pdf", ".docx", ".pptx", ".md", 
    ".csv", ".py", ".js", ".html", ".css",
    ".json", ".yaml", ".xml"
]

# Create embedding model
embed_model = HuggingFaceEmbedding(model_name="all-MiniLM-L6-v2")

# Process each directory
for directory in dirs_to_index:
    dir_path = os.path.expanduser(directory)
    print(f"Indexing {dir_path}...")
    
    # Create documents from directory
    documents = SimpleDirectoryReader(
        input_dir=dir_path,
        recursive=True,
        file_extractor={
            ".pdf": "PyPDFLoader",
            ".docx": "DocxLoader", 
            ".pptx": "PptxLoader"
        },
        required_exts=file_extensions
    ).load_data()
    
    # Create nodes from documents
    parser = SimpleNodeParser.from_defaults(chunk_size=512, chunk_overlap=50)
    nodes = parser.get_nodes_from_documents(documents)
    
    # Create and save index
    storage_context = StorageContext.from_defaults(vector_store=SimpleVectorStore())
    index = VectorStoreIndex(nodes, storage_context=storage_context, embed_model=embed_model)
    
    # Save the index
    index.storage_context.persist("./storage")

print("Indexing complete!")
```

## Step 4: Create the Query Engine

Create a file called `query_engine.py`:

```python
from llama_index import load_index_from_storage, StorageContext
from llama_index.embeddings.huggingface import HuggingFaceEmbedding
from llama_index.llms.ollama import Ollama

def get_query_engine():
    # Load the embedding model
    embed_model = HuggingFaceEmbedding(model_name="all-MiniLM-L6-v2")
    
    # Load the LLM
    llm = Ollama(model="llama3:8b", request_timeout=30.0)
    
    # Load the index
    storage_context = StorageContext.from_defaults(persist_dir="./storage")
    index = load_index_from_storage(storage_context, embed_model=embed_model)
    
    # Create the query engine
    query_engine = index.as_query_engine(
        llm=llm,
        similarity_top_k=3,
        streaming=True
    )
    
    return query_engine
```

## Step 5: Create the API Server

Create a file called `app.py`:

```python
from flask import Flask, request, jsonify
from flask_cors import CORS
from query_engine import get_query_engine

app = Flask(__name__)
CORS(app)

# Initialize the query engine
query_engine = get_query_engine()

@app.route('/query', methods=['POST'])
def process_query():
    data = request.json
    query_text = data.get('query', '')
    
    if not query_text:
        return jsonify({"error": "No query provided"}), 400
    
    # Get response from query engine
    response = query_engine.query(query_text)
    
    return jsonify({
        "response": str(response),
        "sources": [node.metadata for node in response.source_nodes]
    })

if __name__ == '__main__':
    app.run(port=5000)
```

## Step 6: Build the Spotlight-like UI

For a Spotlight-like interface, we'll use Swift and SwiftUI to create a macOS app:

1. Open Xcode and create a new macOS app project
2. Configure the app to launch with a keyboard shortcut (e.g., Option+Space)
3. Create a floating search bar with SwiftUI

Here's a basic structure for the Swift code:

```swift
import SwiftUI

@main
struct LLMAssistantApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "magnifyingglass", accessibilityDescription: "LLM Assistant")
        }
        
        // Create the popover
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 600, height: 300)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: ContentView())
        self.popover = popover
        
        // Register keyboard shortcut (Option+Space)
        NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
            if event.modifierFlags.contains(.option) && event.keyCode == 49 { // Space key
                self.togglePopover()
            }
        }
    }
    
    func togglePopover() {
        if let button = statusItem?.button {
            if popover?.isShown ?? false {
                popover?.performClose(nil)
            } else {
                popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                // Bring to front and focus the text field
                NSApplication.shared.activate(ignoringOtherApps: true)
            }
        }
    }
}

struct ContentView: View {
    @State private var queryText: String = ""
    @State private var responseText: String = ""
    @State private var isLoading: Bool = false
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Ask about your files...", text: $queryText, onCommit: performQuery)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(0.7)
                }
            }
            .padding(10)
            .background(Color(.textBackgroundColor))
            .cornerRadius(8)
            
            if !responseText.isEmpty {
                ScrollView {
                    Text(responseText)
                        .padding()
                }
                .background(Color(.windowBackgroundColor))
                .cornerRadius(8)
            }
        }
        .padding()
        .frame(width: 600)
    }
    
    func performQuery() {
        guard !queryText.isEmpty else { return }
        
        isLoading = true
        responseText = "Thinking..."
        
        let url = URL(string: "http://localhost:5000/query")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["query": queryText]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    responseText = "Error: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    responseText = "No data received"
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let response = json["response"] as? String {
                        responseText = response
                    }
                } catch {
                    responseText = "Error parsing response: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}
```

## Step 7: Package Everything Together

1. Create an application launcher script:

```bash
#!/bin/bash
# Start the backend server
cd ~/llm-assistant
 
python app.py &
# Wait for server to start
sleep 3
# Launch the macOS app
open /Applications/LLMAssistant.app
```

2. Build and export your Xcode project to create the app

3. Set up the indexer to run periodically:
   - Create a LaunchAgent to run the indexer daily or on startup
   - Or set up a cron job

## Usage

1. Press Option+Space to bring up the assistant
2. Type your question about your files
3. Get answers based on the content of your indexed documents

## Performance Optimization

- Use quantization for the model (Ollama supports this automatically)
- Adjust chunk size and overlap based on your content types
- Set up selective indexing for only the most important directories
- Consider updating to a faster embedding model if needed

## Additional Features to Consider

- File preview in results
- Direct links to source documents
- History of recent queries
- Customizable appearance and keyboard shortcuts
- Option to fine-tune the model on your specific content