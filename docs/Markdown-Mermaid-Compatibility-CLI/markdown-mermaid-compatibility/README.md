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
