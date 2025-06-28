# Zerox CLI Usage Guide

This guide shows you how to use Zerox to convert PDF documents to Markdown using OpenAI vision models, both locally and with Docker.

## Prerequisites

1. **OpenAI API Key**: Get your API key from [OpenAI](https://platform.openai.com/api-keys)
2. **Docker** (for Docker usage): Install from [docker.com](https://www.docker.com/get-started)

## Quick Start with Docker (Recommended)

The easiest way to use Zerox is with the provided Docker script:

### 1. Set your OpenAI API key
```bash
export OPENAI_API_KEY="your-api-key-here"
```

### 2. Run the conversion
```bash
# Basic usage
./run-docker.sh your-document.pdf

# Specify output file
./run-docker.sh document.pdf output.md

# Use GPT-4o with format preservation
./run-docker.sh document.pdf output.md --model gpt-4o --maintain-format
```

### 3. Find your converted markdown
The output will be saved in the `output/` directory, and if you specified a custom output path, it will also be copied there.

## Docker Usage Options

### Using the shell script (easiest)
```bash
./run-docker.sh <input-file> [output-file] [options]
```

### Using docker-compose
```bash
# First, place your PDF in the input/ directory
mkdir -p input output
cp your-document.pdf input/

# Run conversion
docker-compose run --rm zerox convert -i /app/input/your-document.pdf -o /app/output/result.md
```

### Using Docker directly
```bash
# Build the image
docker build -t zerox-cli .

# Run conversion
docker run --rm \
  -e OPENAI_API_KEY="$OPENAI_API_KEY" \
  -v "$(pwd)/input:/app/input" \
  -v "$(pwd)/output:/app/output" \
  zerox-cli convert \
  -i /app/input/your-document.pdf \
  -o /app/output/result.md
```

## Local Development Usage

### 1. Install dependencies
```bash
npm install
```

### 2. Build the project
```bash
npm run build
```

### 3. Run the CLI
```bash
# Set your API key
export OPENAI_API_KEY="your-api-key-here"

# Run conversion
npm run cli convert -i path/to/your/document.pdf -o output.md
```

### Alternative: Direct TypeScript execution
```bash
npx ts-node cli.ts convert -i document.pdf -o output.md
```

## CLI Options

```
Convert PDF to Markdown

Options:
  -i, --input <path>         Input PDF file path or URL (required)
  -o, --output <path>        Output markdown file path (default: input filename with .md extension)
  -k, --api-key <key>        OpenAI API key (or set OPENAI_API_KEY env var)
  -m, --model <model>        OpenAI model to use (gpt-4o, gpt-4o-mini) (default: "gpt-4o-mini")
  -c, --concurrency <number> Number of concurrent requests (default: "10")
  --maintain-format          Maintain formatting consistency (slower but better for tables)
  --no-cleanup               Keep temporary files after processing
  -h, --help                 display help for command
```

## Examples

### Basic conversion
```bash
./run-docker.sh document.pdf
```

### Convert with custom output file
```bash
./run-docker.sh report.pdf converted-report.md
```

### Use GPT-4o model for better quality
```bash
./run-docker.sh document.pdf output.md --model gpt-4o
```

### Maintain table formatting (slower but more accurate)
```bash
./run-docker.sh document.pdf output.md --maintain-format
```

### Higher concurrency for faster processing
```bash
./run-docker.sh document.pdf output.md --concurrency 20
```

### Convert from URL
```bash
npm run cli convert -i "https://example.com/document.pdf" -o output.md
```

## Supported File Types

Zerox supports various document formats:

- **PDF**: Direct processing
- **Office Documents**: DOC, DOCX, XLS, XLSX, PPT, PPTX
- **Images**: PNG, JPG, JPEG, HEIC
- **Text Formats**: TXT, RTF, HTML, XML
- **OpenDocument**: ODT, ODS, ODP

## Environment Variables

- `OPENAI_API_KEY`: Your OpenAI API key (required)

## Output

The CLI will create a markdown file containing:
- Converted text from all pages
- Proper markdown formatting
- Page separators (`---`) between pages
- Statistics about the conversion process

## Troubleshooting

### Docker Issues
```bash
# Check if Docker is running
docker info

# Rebuild the image if needed
docker build -t zerox-cli . --no-cache
```

### Permission Issues
```bash
# Make sure the script is executable
chmod +x run-docker.sh

# Check file permissions for input files
ls -la your-document.pdf
```

### API Key Issues
```bash
# Verify your API key is set
echo $OPENAI_API_KEY

# Test with a simple OpenAI call
curl -H "Authorization: Bearer $OPENAI_API_KEY" https://api.openai.com/v1/models
```

### Memory Issues
- For large documents, reduce concurrency: `--concurrency 5`
- Use GPT-4o-mini instead of GPT-4o for lower memory usage

## Cost Considerations

- **GPT-4o-mini**: ~$0.15-0.60 per document (recommended for most use cases)
- **GPT-4o**: ~$3-15 per document (higher quality, especially for complex layouts)

Cost depends on document size, number of pages, and image resolution. The CLI shows token usage after conversion to help you track costs.