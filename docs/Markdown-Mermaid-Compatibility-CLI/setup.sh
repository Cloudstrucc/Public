#!/bin/bash

# Create directory for the tool if not already in it
TOOL_DIR="markdown-mermaid-compatibility"
if [ "$(basename $(pwd))" != "$TOOL_DIR" ]; then
  echo "Creating directory: $TOOL_DIR"
  mkdir -p "$TOOL_DIR"
  cd "$TOOL_DIR"
fi

echo "Setting up Markdown Mermaid Compatibility CLI in $(pwd)"

# Create index.js
echo "Creating index.js..."
cat > index.js << 'EOF'
#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { program } = require('commander');
const glob = require('glob');

program
  .name('mdmerge')
  .description('CLI tool to create platform-specific versions of markdown files with Mermaid diagrams')
  .version('1.0.0');

program
  .command('convert')
  .description('Convert markdown files with Mermaid diagrams to platform-specific versions')
  .argument('<patterns...>', 'markdown files to convert (glob patterns supported)')
  .option('--github', 'create GitHub-compatible versions')
  .option('--azure-devops', 'create Azure DevOps-compatible versions (default)')
  .option('-o, --output <dir>', 'output directory for converted files')
  .option('-s, --suffix <suffix>', 'suffix for converted files')
  .option('-f, --force', 'overwrite existing files without prompting')
  .option('-p, --preserve-original', 'keep the original syntax in comments')
  .option('-v, --verbose', 'verbose output')
  .action(async (patterns, options) => {
    // Set default options
    if (!options.github && !options.azureDevops) {
      options.azureDevops = true; // Default to Azure DevOps if neither is specified
    }

    // Process each pattern to find matching files
    let allFiles = [];
    for (const pattern of patterns) {
      try {
        const files = glob.sync(pattern);
        if (files.length === 0) {
          console.warn(`Warning: No files found matching pattern: ${pattern}`);
        }
        allFiles = [...allFiles, ...files];
      } catch (error) {
        console.error(`Error processing pattern ${pattern}:`, error.message);
      }
    }

    // Remove duplicates
    allFiles = [...new Set(allFiles)];

    if (allFiles.length === 0) {
      console.error('Error: No files found matching the provided patterns.');
      process.exit(1);
    }

    if (options.verbose) {
      console.log(`Found ${allFiles.length} files to process.`);
    }

    // Process each file
    for (const file of allFiles) {
      try {
        // Skip non-markdown files
        if (!file.endsWith('.md')) {
          if (options.verbose) {
            console.log(`Skipping non-markdown file: ${file}`);
          }
          continue;
        }

        const content = fs.readFileSync(file, 'utf8');
        const hasMermaid = content.includes('```mermaid') || content.includes(':::mermaid');
        
        if (!hasMermaid) {
          if (options.verbose) {
            console.log(`No Mermaid diagrams found in: ${file}`);
          }
          continue;
        }

        const dirname = options.output || path.dirname(file);
        const basename = path.basename(file, path.extname(file));
        const ext = path.extname(file);

        // Create directory if it doesn't exist
        if (!fs.existsSync(dirname)) {
          fs.mkdirSync(dirname, { recursive: true });
        }

        // Create Azure DevOps version
        if (options.azureDevops) {
          const suffix = options.suffix || '_devops';
          const outputFile = path.join(dirname, `${basename}${suffix}${ext}`);
          
          // Check if file exists and force option is not set
          if (fs.existsSync(outputFile) && !options.force) {
            console.error(`Error: File already exists: ${outputFile}. Use --force to overwrite.`);
            continue;
          }
          
          const azureDevopsContent = convertToAzureDevops(content, options.preserveOriginal);
          fs.writeFileSync(outputFile, azureDevopsContent);
          console.log(`Created Azure DevOps compatible file: ${outputFile}`);
        }

        // Create GitHub version
        if (options.github) {
          const suffix = options.suffix || '_github';
          const outputFile = path.join(dirname, `${basename}${suffix}${ext}`);
          
          // Check if file exists and force option is not set
          if (fs.existsSync(outputFile) && !options.force) {
            console.error(`Error: File already exists: ${outputFile}. Use --force to overwrite.`);
            continue;
          }
          
          const githubContent = convertToGithub(content, options.preserveOriginal);
          fs.writeFileSync(outputFile, githubContent);
          console.log(`Created GitHub compatible file: ${outputFile}`);
        }
      } catch (error) {
        console.error(`Error processing file ${file}:`, error.message);
      }
    }
  });

program
  .command('watch')
  .description('Watch markdown files and convert them when they change')
  .argument('<patterns...>', 'markdown files to watch (glob patterns supported)')
  .option('--github', 'create GitHub-compatible versions')
  .option('--azure-devops', 'create Azure DevOps-compatible versions (default)')
  .option('-o, --output <dir>', 'output directory for converted files')
  .option('-s, --suffix <suffix>', 'suffix for converted files')
  .option('-f, --force', 'overwrite existing files without prompting')
  .option('-p, --preserve-original', 'keep the original syntax in comments')
  .action((patterns, options) => {
    console.log('Watching for changes in markdown files...');
    console.log('Press Ctrl+C to stop.');
    
    // Use the same options for the convert command
    const convertOptions = { ...options };
    
    // Initial conversion
    program.commands[0].action(patterns, convertOptions);
    
    // Set up file watching
    const watchFiles = glob.sync(patterns);
    
    for (const file of watchFiles) {
      fs.watch(file, (eventType) => {
        if (eventType === 'change') {
          console.log(`\nFile changed: ${file}`);
          program.commands[0].action([file], convertOptions);
        }
      });
    }
  });

/**
 * Convert markdown content to Azure DevOps compatible format
 * @param {string} content - The markdown content
 * @param {boolean} preserveOriginal - Whether to keep the original syntax in comments
 * @returns {string} - The converted content
 */
function convertToAzureDevops(content, preserveOriginal) {
  if (preserveOriginal) {
    return content.replace(/```mermaid\n([\s\S]*?)```/g, (match, diagramContent) => {
      return `:::mermaid\n${diagramContent}:::\n\n<!-- Original GitHub format:\n\`\`\`mermaid\n${diagramContent}\`\`\`\n-->`;
    });
  } else {
    return content.replace(/```mermaid\n([\s\S]*?)```/g, ':::mermaid\n$1:::');
  }
}

/**
 * Convert markdown content to GitHub compatible format
 * @param {string} content - The markdown content
 * @param {boolean} preserveOriginal - Whether to keep the original syntax in comments
 * @returns {string} - The converted content
 */
function convertToGithub(content, preserveOriginal) {
  if (preserveOriginal) {
    return content.replace(/:::mermaid\n([\s\S]*?):::/g, (match, diagramContent) => {
      return `\`\`\`mermaid\n${diagramContent}\`\`\`\n\n<!-- Original Azure DevOps format:\n:::mermaid\n${diagramContent}:::\n-->`;
    });
  } else {
    return content.replace(/:::mermaid\n([\s\S]*?):::/g, '```mermaid\n$1```');
  }
}

program.parse();
EOF

# Make the script executable
chmod +x index.js

# Create package.json
echo "Creating package.json..."
cat > package.json << 'EOF'
{
  "name": "markdown-mermaid-compatibility",
  "version": "1.0.0",
  "description": "CLI tool to create platform-specific versions of markdown files with Mermaid diagrams",
  "main": "index.js",
  "bin": {
    "markdown-mermaid-compatibility": "./index.js",
    "mdmerge": "./index.js"
  },
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "keywords": [
    "markdown",
    "mermaid",
    "azure-devops",
    "github",
    "cli"
  ],
  "author": "",
  "license": "MIT",
  "dependencies": {
    "commander": "^11.0.0",
    "glob": "^10.3.3"
  }
}
EOF

# Create README.md
echo "Creating README.md..."
cat > README.md << 'EOF'
# Markdown Mermaid Compatibility CLI

A command-line tool that creates platform-specific versions of markdown files containing Mermaid diagrams for compatibility with different platforms like GitHub and Azure DevOps.

## Problem

Different platforms use different syntax for rendering Mermaid diagrams in markdown:

- GitHub uses: `` ```mermaid ``
- Azure DevOps uses: `:::mermaid`

This tool lets you maintain a single source file and automatically generate platform-specific versions.

## Installation

```bash
# Clone the repository
git clone <repository-url>
cd markdown-mermaid-compatibility

# Install dependencies
npm install

# Install globally
npm install -g .
```

## Usage

### Basic Usage

Convert a markdown file to Azure DevOps format (default):

```bash
mdmerge convert path/to/your/file.md
```

This will create `path/to/your/file_devops.md` with the Azure DevOps compatible Mermaid syntax.

### Advanced Options

```bash
# Create both GitHub and Azure DevOps versions
mdmerge convert path/to/your/file.md --github --azure-devops

# Specify a custom suffix
mdmerge convert path/to/your/file.md --suffix _azdo

# Specify an output directory
mdmerge convert path/to/your/file.md -o output/dir

# Process multiple files
mdmerge convert file1.md file2.md

# Process all markdown files in a directory
mdmerge convert *.md
```

### Watch Mode

Watch markdown files and convert them when they change:

```bash
mdmerge watch *.md
```

## Conversion Rules

- For Azure DevOps: Replaces `` ```mermaid `` blocks with `:::mermaid` blocks
- For GitHub: Ensures diagrams use the `` ```mermaid `` format

## Integration with Your Workflow

### Add to package.json scripts

```json
"scripts": {
  "generate-docs": "mdmerge convert docs/*.md"
}
```

### Use with Git Hooks

You can use this tool with pre-commit or pre-push hooks to automatically generate platform-specific versions when you commit or push changes.

## License

MIT
EOF

# Install dependencies
echo "Installing dependencies..."
npm install

echo "Setup complete. You can now use the Markdown Mermaid Compatibility CLI."
echo ""
echo "Try it out with your markdown files containing Mermaid diagrams:"
echo "node index.js convert path/to/your/file.md"
echo ""
echo "Or install it globally to use from anywhere:"
echo "npm install -g ."
echo "mdmerge convert path/to/your/file.md"