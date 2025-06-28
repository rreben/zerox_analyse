#!/bin/bash

# Zerox Docker Runner Script
# Usage: ./run-docker.sh <input-file> [output-file] [options]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_usage() {
    echo -e "${BLUE}Zerox Docker Runner${NC}"
    echo "Convert PDF and other documents to Markdown using OpenAI vision models"
    echo ""
    echo "Usage: $0 <input-file> [output-file] [options]"
    echo ""
    echo "Arguments:"
    echo "  input-file    Path to the input PDF file (required)"
    echo "  output-file   Path to the output markdown file (optional)"
    echo ""
    echo "Options:"
    echo "  --model MODEL         OpenAI model to use (gpt-4o, gpt-4o-mini) [default: gpt-4o-mini]"
    echo "  --concurrency NUM     Number of concurrent requests [default: 10]"
    echo "  --maintain-format     Maintain formatting consistency (slower but better for tables)"
    echo "  --api-key KEY         OpenAI API key (or set OPENAI_API_KEY env var)"
    echo ""
    echo "Examples:"
    echo "  $0 document.pdf"
    echo "  $0 document.pdf output.md"
    echo "  $0 document.pdf output.md --model gpt-4o --maintain-format"
    echo ""
    echo "Environment variables:"
    echo "  OPENAI_API_KEY        Your OpenAI API key (required)"
}

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Error: Docker is not running. Please start Docker and try again.${NC}"
    exit 1
fi

# Check if help is requested or no arguments
if [[ $# -eq 0 ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    print_usage
    exit 0
fi

# Check if API key is set
if [[ -z "$OPENAI_API_KEY" ]]; then
    echo -e "${RED}❌ Error: OPENAI_API_KEY environment variable is not set.${NC}"
    echo "Please set your OpenAI API key:"
    echo "  export OPENAI_API_KEY='your-api-key-here'"
    exit 1
fi

INPUT_FILE="$1"
OUTPUT_FILE="$2"

# Check if input file exists
if [[ ! -f "$INPUT_FILE" ]]; then
    echo -e "${RED}❌ Error: Input file '$INPUT_FILE' does not exist.${NC}"
    exit 1
fi

# Create input and output directories
mkdir -p input output

# Copy input file to input directory
INPUT_BASENAME=$(basename "$INPUT_FILE")
cp "$INPUT_FILE" "input/$INPUT_BASENAME"

# Determine output file name
if [[ -z "$OUTPUT_FILE" ]]; then
    OUTPUT_BASENAME="${INPUT_BASENAME%.*}.md"
else
    OUTPUT_BASENAME=$(basename "$OUTPUT_FILE")
fi

# Build remaining arguments for the CLI
ARGS=()
shift 1 # Remove input file argument
if [[ -n "$OUTPUT_FILE" ]]; then
    shift 1 # Remove output file argument if provided
fi

# Add remaining arguments
while [[ $# -gt 0 ]]; do
    ARGS+=("$1")
    shift
done

echo -e "${BLUE}🚀 Starting Zerox Docker conversion...${NC}"
echo -e "${YELLOW}📄 Input file: $INPUT_FILE${NC}"
echo -e "${YELLOW}📝 Output file: output/$OUTPUT_BASENAME${NC}"

# Build Docker image
echo -e "${BLUE}🔨 Building Docker image...${NC}"
docker build -t zerox-cli .

# Run conversion
echo -e "${BLUE}⚡ Converting document...${NC}"
docker run --rm \
    -e OPENAI_API_KEY="$OPENAI_API_KEY" \
    -v "$(pwd)/input:/app/input" \
    -v "$(pwd)/output:/app/output" \
    zerox-cli convert \
    -i "/app/input/$INPUT_BASENAME" \
    -o "/app/output/$OUTPUT_BASENAME" \
    "${ARGS[@]}"

# Check if conversion was successful
if [[ -f "output/$OUTPUT_BASENAME" ]]; then
    echo -e "${GREEN}✅ Conversion completed successfully!${NC}"
    echo -e "${GREEN}📝 Output saved to: output/$OUTPUT_BASENAME${NC}"
    
    # Optionally copy to specified output location
    if [[ -n "$OUTPUT_FILE" ]] && [[ "$OUTPUT_FILE" != "$OUTPUT_BASENAME" ]]; then
        cp "output/$OUTPUT_BASENAME" "$OUTPUT_FILE"
        echo -e "${GREEN}📄 Also copied to: $OUTPUT_FILE${NC}"
    fi
else
    echo -e "${RED}❌ Conversion failed. Check the output above for errors.${NC}"
    exit 1
fi