# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Node.js (Primary Development)
- **Build**: `npm run build` - Compiles TypeScript and creates distribution
- **Clean**: `npm run clean` - Removes dist directory
- **Test**: `npm test` - Runs basic integration tests
- **Performance Test**: `npm run test:performance` - Runs Jest performance tests
- **Install Dependencies**: `npm install` (automatically runs postinstall script)

### Python Development
- **Setup Environment**: `make venv` - Creates Python virtual environment
- **Build Package**: `make build` - Builds Python package using setuptools
- **Test**: `make test` - Runs pytest on py_zerox/tests
- **Lint**: `make lint` - Runs ruff linting on source and tests
- **Format**: `make format` - Runs black formatting checks
- **Fix Issues**: `make fix` - Auto-fixes linting and formatting issues
- **Development Install**: `make dev` - Installs package in editable mode

## Architecture Overview

This is a **dual-language OCR library** that converts documents to markdown using vision language models:

### Core Structure
- **node-zerox/**: Node.js/TypeScript implementation (primary)
  - `src/index.ts`: Main entry point with `zerox()` function  
  - `src/models/`: Model providers (OpenAI, Azure, Bedrock, Google)
  - `src/utils/`: PDF conversion, image processing, file handling
  - `src/types.ts`: TypeScript definitions
- **py_zerox/**: Python implementation using LiteLLM
  - `pyzerox/core/zerox.py`: Main Python API
  - `pyzerox/models/`: Model abstraction layer
  - `pyzerox/processor/`: Document processing utilities

### Processing Pipeline
1. **File Input**: PDFs, images, Office documents, spreadsheets
2. **Conversion**: Files → PDF → Images (using GraphicsMagick/Poppler)  
3. **Image Processing**: Compression, orientation correction, edge trimming
4. **OCR**: Images sent to vision models (GPT-4o, Claude, Gemini) for markdown conversion
5. **Extraction**: Optional structured data extraction using JSON schemas
6. **Output**: Aggregated markdown + metadata

### Model Support
- **OpenAI**: GPT-4o, GPT-4o-mini via direct API
- **Azure OpenAI**: Same models via Azure endpoints
- **AWS Bedrock**: Claude 3 family (Haiku, Sonnet, Opus)
- **Google**: Gemini 1.5/2.0 variants
- **Custom**: Extensible via `customModelFunction` parameter

## Key Features
- **Concurrent Processing**: Configurable page-level parallelism
- **Format Preservation**: `maintainFormat` option for consistent table formatting
- **Data Extraction**: Schema-based structured data extraction
- **Hybrid Mode**: Combines OCR text + images for extraction
- **Error Handling**: Configurable error modes (throw/ignore)
- **Docker Support**: Full containerized execution

## Testing
- Node tests use custom test runner (`ts-node node-zerox/tests/index.ts`)
- Performance tests use Jest
- Python tests use pytest
- Test data includes various document formats in `shared/inputs/`

## Dependencies
### System Requirements
- **Node.js**: GraphicsMagick, Ghostscript for PDF processing
- **Python**: Poppler-utils for PDF to image conversion
- Both versions require vision model API credentials

### Key Libraries
- **Node**: pdf2pic, sharp (images), tesseract.js (orientation), openai/aws-sdk
- **Python**: pdf2image, litellm (model abstraction), aiofiles