import { cosineSimilarity, ollamaEmbedding, readJson, readJsonl, tokenize } from '../src/rag-core.mjs';

const query = process.argv.slice(2).join(' ').trim();
if (query.length === 0) {
  console.error('Usage: npm run rag:query -- "Navigation NavDestination 怎么写"');
  process.exit(1);
}

const embeddingConfig = readJson('config/embedding.json');
await assertOllamaReady(embeddingConfig);
const chunks = readJsonl('indexes/vector/chunks.jsonl');
if (chunks.length === 0) {
  console.error('Vector index is empty. Run: npm run rag:build');
  process.exit(1);
}

const queryEmbedding = await ollamaEmbedding(query, embeddingConfig);
const queryTokens = tokenize(query);
const scored = chunks.map((chunk) => {
  const vectorScore = cosineSimilarity(queryEmbedding, chunk.embedding);
  const keywordScore = keywordOverlap(queryTokens, chunk);
  const priorityScore = (chunk.priority ?? 0) / 100;
  const score = vectorScore * embeddingConfig.retrieval.vectorWeight
    + keywordScore * embeddingConfig.retrieval.keywordWeight
    + priorityScore * embeddingConfig.retrieval.priorityWeight;
  return { chunk, score, vectorScore, keywordScore };
}).sort((left, right) => right.score - left.score);

const alwaysTypes = new Set(embeddingConfig.retrieval.alwaysIncludeSourceTypes);
const forced = scored.filter((item) => alwaysTypes.has(item.chunk.sourceType)).slice(0, 2);
const top = mergeUnique([...forced, ...scored], embeddingConfig.retrieval.topK);

for (const [index, item] of top.entries()) {
  const { chunk } = item;
  console.log(`\n#${index + 1} score=${item.score.toFixed(4)} vector=${item.vectorScore.toFixed(4)} keyword=${item.keywordScore.toFixed(4)}`);
  console.log(`[${chunk.sourceType}] ${chunk.path}`);
  console.log(`Title: ${chunk.title}`);
  console.log(chunk.text.slice(0, 1400));
}

function keywordOverlap(tokens, chunk) {
  if (tokens.length === 0) {
    return 0;
  }
  const haystack = `${chunk.title} ${chunk.path} ${chunk.text}`.toLowerCase();
  const hits = tokens.filter((token) => haystack.includes(token)).length;
  return hits / tokens.length;
}

function mergeUnique(items, topK) {
  const seen = new Set();
  const result = [];
  for (const item of items) {
    if (seen.has(item.chunk.id)) {
      continue;
    }
    seen.add(item.chunk.id);
    result.push(item);
    if (result.length >= topK) {
      break;
    }
  }
  return result;
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
