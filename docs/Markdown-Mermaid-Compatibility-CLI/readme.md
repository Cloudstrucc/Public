# mdmerge - Markdown Mermaid Diagram Compatibility Tool

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A lightweight CLI tool that makes your Mermaid diagrams work across different platforms like GitHub and Azure DevOps. Maintain a single source file and automatically generate platform-specific versions for each destination.

## The Problem

Different platforms use different syntax for rendering Mermaid diagrams in Markdown:

- GitHub, VS Code, and most platforms use:  | ```mermaid` |
- Azure DevOps uses: | `:::mermaid` |

This tool solves the compatibility issue by generating properly formatted files for each platform while you maintain a single source readme file by enabling the ability for users to manually or automatically convert a Markdown file (or multiple files) with embedded mermaid.js diagrams to be duplicated to support Azure DevOps (and others as the the project matures).  For now it supports the mermaid diagram rendering in DevOps.

## Installation

### Option 1: From NPM

```bash
# Coming soon: Install from npm
npm install -g mdmerge
```

### Option 2: From Source

```bash
# Clone the repository
git clone https://github.com/yourusername/mdmerge.git
cd mdmerge

# Install dependencies
npm install

# Install globally
npm install -g .
```

### Option 3: Quick Setup Script

```bash
# Run the setup script
curl -o setup-mdmerge.sh https://raw.githubusercontent.com/yourusername/mdmerge/main/setup-mdmerge.sh
chmod +x setup-mdmerge.sh
./setup-mdmerge.sh
```

## Usage

### Basic Commands

```bash
# Convert a file to Azure DevOps format (default)
mdmerge convert README.md

# Convert a file and create versions for both GitHub and Azure DevOps
mdmerge convert README.md --github --azure-devops

# Convert all markdown files in a directory
mdmerge convert *.md

# Watch for changes and automatically convert
mdmerge watch *.md
```

### Command Options

```bash
# Specify a custom suffix (default: _devops or _github)
mdmerge convert README.md --suffix _azdo

# Specify an output directory
mdmerge convert README.md -o dist/

# Force overwrite existing files
mdmerge convert README.md -f

# Preserve original syntax in comments
mdmerge convert README.md -p

# Enable verbose output
mdmerge convert README.md -v
```

### Workflow Integration

#### NPM Scripts

Add to your `package.json`:

```json
"scripts": {
  "docs:convert": "mdmerge convert docs/*.md",
  "docs:watch": "mdmerge watch docs/*.md"
}
```

#### Git Hooks

Use with tools like Husky to automatically generate platform-specific versions when committing:

```json
"husky": {
  "hooks": {
    "pre-commit": "mdmerge convert docs/*.md"
  }
}
```

## Extending the Tool

The tool is designed to be easily extended with new commands or additional functionality. Here's how:

### Project Structure

```
mdmerge/
├── index.js          # Main entry point and command definitions
├── package.json      # Package configuration
├── README.md         # Documentation
└── lib/              # Library modules (optional for extensions)
```

### Adding a New Command

1. Open `index.js` and locate the command definitions
2. Add your new command using the Commander.js pattern

Example - Adding a "validate" command to check Mermaid syntax:

```javascript
program
  .command('validate')
  .description('Validate Mermaid diagram syntax in markdown files')
  .argument('<patterns...>', 'markdown files to validate')
  .option('-v, --verbose', 'verbose output')
  .action(async (patterns, options) => {
    // Find all files matching the patterns
    let allFiles = [];
    for (const pattern of patterns) {
      try {
        const files = glob.sync(pattern);
        allFiles = [...allFiles, ...files];
      } catch (error) {
        console.error(`Error processing pattern ${pattern}:`, error.message);
      }
    }

    // Process each file
    for (const file of allFiles) {
      // Implementation for validation
      const content = fs.readFileSync(file, 'utf8');
      const mermaidBlocks = extractMermaidBlocks(content);
    
      // Check each Mermaid block
      for (const block of mermaidBlocks) {
        // Add your validation logic here
        console.log(`Validating Mermaid diagram in ${file}`);
      }
    }
  });

// Helper function to extract Mermaid blocks
function extractMermaidBlocks(content) {
  const blocks = [];
  const regex = /(?:```mermaid|:::mermaid)\n([\s\S]*?)(?:```|:::)/g;
  let match;
  while ((match = regex.exec(content))) {
    blocks.push(match[1]);
  }
  return blocks;
}
```

### Adding Conversion Support for a New Platform

To add support for a new platform beyond GitHub and Azure DevOps:

1. Create a new conversion function:

```javascript
function convertToPlatformX(content, preserveOriginal) {
  // Implement conversion logic for the new platform
  // Example: Convert to Platform X format
  return content.replace(/```mermaid\n([\s\S]*?)```/g, '<x-mermaid>\n$1</x-mermaid>');
}
```

2. Add a new option to the convert command:

```javascript
program
  .command('convert')
  .option('--platform-x', 'create Platform X-compatible versions')
  // ... other options ...
```

3. Update the action handler to use the new conversion:

```javascript
if (options.platformX) {
  const suffix = options.suffix || '_platformx';
  const outputFile = path.join(dirname, `${basename}${suffix}${ext}`);
  
  if (fs.existsSync(outputFile) && !options.force) {
    console.error(`Error: File already exists: ${outputFile}. Use --force to overwrite.`);
    continue;
  }
  
  const platformXContent = convertToPlatformX(content, options.preserveOriginal);
  fs.writeFileSync(outputFile, platformXContent);
  console.log(`Created Platform X compatible file: ${outputFile}`);
}
```

### Adding New Features

You can also add completely new features to enhance the tool:

1. **Auto-validation**: Add validation of Mermaid syntax before conversion
2. **Preview**: Generate a preview of the diagrams
3. **Export**: Add options to export diagrams directly to PNG/SVG
4. **Custom templates**: Support for custom output templates

Example - Adding a diagram extraction feature:

```javascript
program
  .command('extract')
  .description('Extract Mermaid diagrams from markdown files')
  .argument('<file>', 'markdown file to extract from')
  .option('-o, --output <dir>', 'output directory for extracted diagrams')
  .action((file, options) => {
    const content = fs.readFileSync(file, 'utf8');
    const diagrams = extractMermaidBlocks(content);
  
    const outputDir = options.output || './diagrams';
    if (!fs.existsSync(outputDir)) {
      fs.mkdirSync(outputDir, { recursive: true });
    }
  
    diagrams.forEach((diagram, index) => {
      const filename = path.join(outputDir, `diagram_${index + 1}.mmd`);
      fs.writeFileSync(filename, diagram);
      console.log(`Extracted diagram to ${filename}`);
    });
  });
```

## PDF Export Support

To export Markdown files with Mermaid diagrams to PDF, we recommend:

1. **VS Code Extension**: Install "Markdown Preview Enhanced" extension

   - Extension ID: `shd101wyy.markdown-preview-enhanced`
2. **Export Process**:

   - Open your Markdown file in VS Code
   - Use Command Palette (Ctrl+Shift+P) to run "Markdown Preview Enhanced: Open Preview"
   - When preview looks good, use "Markdown Preview Enhanced: Export to PDF"

For best results when exporting to PDF, use the GitHub-style Mermaid syntax (```mermaid) in your source files.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- [Commander.js](https://github.com/tj/commander.js/) - For the CLI framework
- [Mermaid](https://mermaid-js.github.io/mermaid/#/) - For the amazing diagramming tool
