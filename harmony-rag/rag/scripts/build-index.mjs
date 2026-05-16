import { appendJsonl, chunkFile, loadSourceFiles, ollamaEmbeddings, readJson, readJsonl, tokenize, writeJson } from '../src/rag-core.mjs';

const embeddingConfig = readJson('config/embedding.json');
await assertOllamaReady(embeddingConfig);
const vectorPath = 'indexes/vector/chunks.jsonl';
const keywordPath = 'indexes/keyword/keywords.json';
const existing = readJsonl(vectorPath);
const indexedIds = new Set(existing.map((row) => row.id));
const files = loadSourceFiles();
let totalChunks = 0;
let embeddedChunks = 0;
const keywordIndex = Object.create(null);
const pending = [];

for (const file of files) {
  const chunks = chunkFile(file, embeddingConfig.chunk);
  totalChunks += chunks.length;
  for (const chunk of chunks) {
    updateKeywordIndex(keywordIndex, chunk);
    if (indexedIds.has(chunk.id)) {
      continue;
    }
    pending.push(chunk);
    if (pending.length >= embeddingConfig.batchSize) {
      embeddedChunks += await flushPending();
      console.log(`Embedded ${embeddedChunks} new chunks...`);
    }
  }
}

if (pending.length > 0) {
  embeddedChunks += await flushPending();
  console.log(`Embedded ${embeddedChunks} new chunks...`);
}

writeJson(keywordPath, {
  generatedAt: new Date().toISOString(),
  totalChunks,
  terms: keywordIndex
});
writeJson('reports/index-summary.json', {
  generatedAt: new Date().toISOString(),
  totalChunks,
  existingChunks: existing.length,
  embeddedChunks,
  vectorPath,
  keywordPath,
  model: embeddingConfig.model
});

console.log(`Total chunks: ${totalChunks}`);
console.log(`New embeddings: ${embeddedChunks}`);
console.log('Index: indexes/vector/chunks.jsonl');

function updateKeywordIndex(index, chunk) {
  for (const token of tokenize(`${chunk.title} ${chunk.path} ${chunk.text}`)) {
    if (!Array.isArray(index[token])) {
      index[token] = [];
    }
    index[token].push(chunk.id);
  }
}

async function flushPending() {
  const chunks = pending.splice(0);
  const inputs = chunks.map((chunk) => `${chunk.title}\n${chunk.path}\n${chunk.text}`);
  const embeddings = await ollamaEmbeddings(inputs, embeddingConfig);
  if (embeddings.length !== chunks.length) {
    throw new Error(`Ollama returned ${embeddings.length} embeddings for ${chunks.length} chunks`);
  }
  const rows = chunks.map((chunk, index) => ({ ...chunk, embedding: embeddings[index] }));
  appendJsonl(vectorPath, rows);
  return rows.length;
}

async function assertOllamaReady(config) {
  try {
    const response = await fetch(`${config.baseUrl}/api/tags`);
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }
    const data = await response.json();
    const models = (data.models ?? []).map((model) => model.name);
    if (!models.some((name) => name === config.model || name.startsWith(`${config.model}:`))) {
      throw new Error(`model ${config.model} is not installed`);
    }
  } catch (error) {
    console.error(`Ollama is not ready: ${error.message}`);
    console.error('Install and prepare Ollama first:');
    console.error('  winget install Ollama.Ollama');
    console.error(`  ollama pull ${config.model}`);
    process.exit(1);
  }
}
