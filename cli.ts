#!/usr/bin/env node

import { program } from 'commander';
import { zerox } from './node-zerox/dist/index.js';
import { ModelOptions, ModelProvider } from './node-zerox/dist/types.js';
import * as fs from 'fs';
import * as path from 'path';

interface CliOptions {
  input: string;
  output?: string;
  apiKey?: string;
  model?: string;
  concurrency?: string;
  maintainFormat?: boolean;
  cleanup?: boolean;
}

async function convertPdfToMarkdown(options: CliOptions) {
  const apiKey = options.apiKey || process.env.OPENAI_API_KEY;
  
  if (!apiKey) {
    console.error('❌ Error: OpenAI API key is required. Set OPENAI_API_KEY environment variable or use --api-key option.');
    process.exit(1);
  }

  if (!options.input) {
    console.error('❌ Error: Input file path is required.');
    process.exit(1);
  }

  // Check if input file exists (for local files)
  if (!options.input.startsWith('http') && !fs.existsSync(options.input)) {
    console.error(`❌ Error: Input file does not exist: ${options.input}`);
    process.exit(1);
  }

  const modelMap: Record<string, ModelOptions> = {
    'gpt-4o': ModelOptions.OPENAI_GPT_4O,
    'gpt-4o-mini': ModelOptions.OPENAI_GPT_4O_MINI,
  };

  const selectedModel = modelMap[options.model || 'gpt-4o-mini'] || ModelOptions.OPENAI_GPT_4O_MINI;

  console.log('🚀 Starting PDF to Markdown conversion...');
  console.log(`📄 Input: ${options.input}`);
  console.log(`🤖 Model: ${options.model || 'gpt-4o-mini'}`);
  console.log(`⚡ Concurrency: ${options.concurrency || '10'}`);

  try {
    const result = await zerox({
      filePath: options.input,
      credentials: {
        apiKey: apiKey,
      },
      model: selectedModel,
      modelProvider: ModelProvider.OPENAI,
      concurrency: parseInt(options.concurrency || '10'),
      maintainFormat: options.maintainFormat || false,
      cleanup: options.cleanup !== false,
      outputDir: options.output ? path.dirname(options.output) : undefined,
    });

    // Generate output filename if not specified
    let outputPath: string;
    if (options.output) {
      outputPath = options.output;
    } else {
      const inputBasename = path.basename(options.input, path.extname(options.input));
      outputPath = `${inputBasename}.md`;
    }

    // Combine all pages into markdown content
    const markdownContent = result.pages
      .map(page => page.content)
      .join('\n\n---\n\n');

    // Write to file
    fs.writeFileSync(outputPath, markdownContent, 'utf8');

    console.log('✅ Conversion completed successfully!');
    console.log(`📝 Output saved to: ${outputPath}`);
    console.log(`📊 Stats:`);
    console.log(`   - Pages processed: ${result.pages.length}`);
    console.log(`   - Input tokens: ${result.inputTokens}`);
    console.log(`   - Output tokens: ${result.outputTokens}`);
    console.log(`   - Completion time: ${result.completionTime}ms`);
    console.log(`   - Successful OCR requests: ${result.summary.ocr?.successful || 0}`);
    console.log(`   - Failed OCR requests: ${result.summary.ocr?.failed || 0}`);

  } catch (error) {
    console.error('❌ Error during conversion:', error);
    process.exit(1);
  }
}

program
  .name('zerox-cli')
  .description('Convert PDF and other documents to Markdown using OpenAI vision models')
  .version('1.0.0');

program
  .command('convert')
  .description('Convert PDF to Markdown')
  .requiredOption('-i, --input <path>', 'Input PDF file path or URL')
  .option('-o, --output <path>', 'Output markdown file path (default: input filename with .md extension)')
  .option('-k, --api-key <key>', 'OpenAI API key (or set OPENAI_API_KEY env var)')
  .option('-m, --model <model>', 'OpenAI model to use (gpt-4o, gpt-4o-mini)', 'gpt-4o-mini')
  .option('-c, --concurrency <number>', 'Number of concurrent requests', '10')
  .option('--maintain-format', 'Maintain formatting consistency (slower but better for tables)')
  .option('--no-cleanup', 'Keep temporary files after processing')
  .action(convertPdfToMarkdown);

program.parse();