import { readJson, readJsonl } from '../src/rag-core.mjs';

const summary = readJson('reports/index-summary.json');
const chunks = readJsonl('indexes/vector/chunks.jsonl');
const byType = {};
for (const chunk of chunks) {
  byType[chunk.sourceType] = (byType[chunk.sourceType] ?? 0) + 1;
}

console.log(JSON.stringify({ ...summary, currentVectorRows: chunks.length, byType }, null, 2));
