import fs from 'node:fs';
import { chunkFile, loadSourceFiles, readJson, writeJson } from '../src/rag-core.mjs';

const embeddingConfig = readJson('config/embedding.json');
const files = loadSourceFiles();
const summary = {
  generatedAt: new Date().toISOString(),
  fileCount: files.length,
  chunkCount: 0,
  bySourceType: {},
  byExtension: {}
};

for (const file of files) {
  const stat = fs.statSync(file.absolutePath);
  const chunks = chunkFile(file, embeddingConfig.chunk);
  summary.chunkCount += chunks.length;
  summary.bySourceType[file.sourceType] = (summary.bySourceType[file.sourceType] ?? 0) + 1;
  summary.byExtension[file.extension || '<none>'] = (summary.byExtension[file.extension || '<none>'] ?? 0) + 1;
  file.size = stat.size;
  file.chunkCount = chunks.length;
  delete file.absolutePath;
}

writeJson('reports/source-summary.json', summary);
writeJson('reports/source-manifest.json', { generatedAt: summary.generatedAt, files });

console.log(`Files: ${summary.fileCount}`);
console.log(`Chunks: ${summary.chunkCount}`);
console.log('Report: reports/source-summary.json');
