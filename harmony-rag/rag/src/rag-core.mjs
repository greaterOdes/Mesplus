import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';

export const ROOT = path.resolve(import.meta.dirname, '..');

export function readJson(relativePath) {
  return JSON.parse(fs.readFileSync(path.resolve(ROOT, relativePath), 'utf8'));
}

export function writeJson(relativePath, data) {
  const target = path.resolve(ROOT, relativePath);
  fs.mkdirSync(path.dirname(target), { recursive: true });
  fs.writeFileSync(target, `${JSON.stringify(data, null, 2)}\n`, 'utf8');
}

export function repoRoot() {
  const sources = readJson('config/sources.json');
  return path.resolve(ROOT, sources.repoRoot);
}

export function normalizePath(filePath) {
  return filePath.split(path.sep).join('/');
}

export function sha256(value) {
  return crypto.createHash('sha256').update(value).digest('hex');
}

export function walkFiles(rootDir) {
  const files = [];
  if (!fs.existsSync(rootDir)) {
    return files;
  }
  const entries = fs.readdirSync(rootDir, { withFileTypes: true });
  for (const entry of entries) {
    const fullPath = path.join(rootDir, entry.name);
    if (entry.isDirectory()) {
      files.push(...walkFiles(fullPath));
    } else if (entry.isFile()) {
      files.push(fullPath);
    }
  }
  return files;
}

export function isExcluded(relativePath, excludes) {
  const normalized = normalizePath(relativePath);
  return excludes.some((pattern) => {
    if (pattern.includes('**/')) {
      const token = pattern.replace('**/', '').replace('/**', '').replace('*', '');
      return normalized.includes(token);
    }
    if (pattern.startsWith('**/*.')) {
      return normalized.endsWith(pattern.slice(4));
    }
    return normalized === pattern;
  });
}

export function matchesInclude(relativePath, includes) {
  const normalized = normalizePath(relativePath);
  return includes.some((pattern) => {
    return globToRegExp(pattern).test(normalized);
  });
}

function globToRegExp(pattern) {
  const escaped = pattern
    .replace(/\\/g, '/')
    .replace(/[.+^${}()|[\]\\]/g, '\\$&')
    .replace(/\*\*/g, '::DOUBLE_STAR::')
    .replace(/\*/g, '[^/]*')
    .replace(/::DOUBLE_STAR::/g, '.*');
  return new RegExp(`^${escaped}$`);
}

export function loadSourceFiles() {
  const config = readJson('config/sources.json');
  const base = repoRoot();
  const files = [];
  for (const source of config.sources) {
    const sourceRoot = path.resolve(base, source.path);
    const isSingleFile = fs.existsSync(sourceRoot) && fs.statSync(sourceRoot).isFile();
    const sourceFiles = isSingleFile
      ? [sourceRoot]
      : walkFiles(sourceRoot);
    for (const filePath of sourceFiles) {
      const relativeToSource = isSingleFile ? path.basename(filePath) : normalizePath(path.relative(sourceRoot, filePath));
      const relativeToRepo = normalizePath(path.relative(base, filePath));
      if (isExcluded(relativeToRepo, config.exclude) || !matchesInclude(relativeToSource, source.include)) {
        continue;
      }
      files.push({
        sourceId: source.id,
        sourceType: source.type,
        priority: source.priority,
        path: relativeToRepo,
        absolutePath: filePath,
        extension: path.extname(filePath).toLowerCase()
      });
    }
  }
  return files.sort((left, right) => left.path.localeCompare(right.path));
}

export function readTextFile(filePath) {
  return fs.readFileSync(filePath, 'utf8').replace(/^\uFEFF/, '').replace(/\r\n/g, '\n');
}

export function chunkMarkdown(file, text, options) {
  const sections = [];
  const lines = text.split('\n');
  let title = path.basename(file.path);
  let buffer = [];
  for (const line of lines) {
    const heading = line.match(/^(#{1,6})\s+(.+)$/);
    if (heading && buffer.length > 0) {
      sections.push({ title, content: buffer.join('\n').trim() });
      buffer = [];
    }
    if (heading) {
      title = heading[2].trim();
    }
    buffer.push(line);
  }
  if (buffer.length > 0) {
    sections.push({ title, content: buffer.join('\n').trim() });
  }
  return splitLargeSections(file, sections, options.markdownMaxChars, options.markdownOverlapChars, 'markdown');
}

export function chunkArkTs(file, text, options) {
  const lines = text.split('\n');
  const chunks = [];
  let start = 0;
  for (let index = 0; index < lines.length; index++) {
    const line = lines[index];
    const isBoundary = /^\s*(export\s+)?(struct|class|interface|enum|function)\s+\w+/.test(line) || /^\s*@Component\b/.test(line);
    if (isBoundary && index > start) {
      chunks.push(lines.slice(start, index).join('\n').trim());
      start = index;
    }
  }
  chunks.push(lines.slice(start).join('\n').trim());
  const sections = chunks.filter(Boolean).map((content) => ({
    title: extractCodeTitle(content) ?? path.basename(file.path),
    content
  }));
  return splitLargeSections(file, sections, options.codeMaxChars, options.codeOverlapChars, 'arkts');
}

function extractCodeTitle(content) {
  const match = content.match(/(?:struct|class|interface|enum|function)\s+(\w+)/);
  return match?.[1];
}

function splitLargeSections(file, sections, maxChars, overlapChars, language) {
  const chunks = [];
  for (const section of sections) {
    if (section.content.length <= maxChars) {
      chunks.push(createChunk(file, section.title, section.content, language));
      continue;
    }
    let offset = 0;
    let part = 1;
    while (offset < section.content.length) {
      const content = section.content.slice(offset, offset + maxChars);
      chunks.push(createChunk(file, `${section.title} #${part}`, content, language));
      offset += Math.max(1, maxChars - overlapChars);
      part += 1;
    }
  }
  return chunks;
}

function createChunk(file, title, content, language) {
  const text = content.trim();
  return {
    id: sha256(`${file.sourceId}:${file.path}:${title}:${text}`),
    sourceId: file.sourceId,
    sourceType: file.sourceType,
    priority: file.priority,
    path: file.path,
    title,
    language,
    text,
    hash: sha256(text)
  };
}

export function chunkFile(file, chunkOptions) {
  const text = readTextFile(file.absolutePath);
  if (file.extension === '.md') {
    return chunkMarkdown(file, text, chunkOptions);
  }
  if (file.extension === '.ets') {
    return chunkArkTs(file, text, chunkOptions);
  }
  return [createChunk(file, path.basename(file.path), text, file.extension.replace('.', '') || 'text')];
}

export function tokenize(text) {
  return Array.from(new Set((text.toLowerCase().match(/[\p{Script=Han}]+|[a-z0-9_]+/gu) ?? [])
    .flatMap((token) => token.length > 8 && /^[\p{Script=Han}]+$/u.test(token) ? splitChineseToken(token) : [token])
    .filter((token) => token.length > 1)));
}

function splitChineseToken(token) {
  const values = [];
  for (let index = 0; index < token.length - 1; index++) {
    values.push(token.slice(index, index + 2));
  }
  return values;
}

export function cosineSimilarity(left, right) {
  let dot = 0;
  let leftNorm = 0;
  let rightNorm = 0;
  const length = Math.min(left.length, right.length);
  for (let index = 0; index < length; index++) {
    dot += left[index] * right[index];
    leftNorm += left[index] * left[index];
    rightNorm += right[index] * right[index];
  }
  if (leftNorm === 0 || rightNorm === 0) {
    return 0;
  }
  return dot / (Math.sqrt(leftNorm) * Math.sqrt(rightNorm));
}

export async function ollamaEmbedding(text, embeddingConfig) {
  const embeddings = await ollamaEmbeddings([text], embeddingConfig);
  return embeddings[0];
}

export async function ollamaEmbeddings(texts, embeddingConfig) {
  const payloadTexts = texts.map((text) => truncateForEmbedding(text, embeddingConfig.embeddingMaxChars ?? 4000));
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), embeddingConfig.requestTimeoutMs);
  try {
    const response = await fetch(`${embeddingConfig.baseUrl}/api/embed`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ model: embeddingConfig.model, input: payloadTexts }),
      signal: controller.signal
    });
    if (!response.ok) {
      throw new Error(`Ollama embedding failed: HTTP ${response.status} ${await response.text()}`);
    }
    const data = await response.json();
    if (!Array.isArray(data.embeddings)) {
      throw new Error('Ollama embedding response has no embeddings array');
    }
    return data.embeddings;
  } finally {
    clearTimeout(timeout);
  }
}

export async function ollamaEmbeddingLegacy(text, embeddingConfig) {
  const payloadText = truncateForEmbedding(text, embeddingConfig.embeddingMaxChars ?? 4000);
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), embeddingConfig.requestTimeoutMs);
  try {
    const response = await fetch(`${embeddingConfig.baseUrl}/api/embeddings`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ model: embeddingConfig.model, prompt: payloadText }),
      signal: controller.signal
    });
    if (!response.ok) {
      throw new Error(`Ollama embedding failed: HTTP ${response.status} ${await response.text()}`);
    }
    const data = await response.json();
    if (!Array.isArray(data.embedding)) {
      throw new Error('Ollama embedding response has no embedding array');
    }
    return data.embedding;
  } finally {
    clearTimeout(timeout);
  }
}

function truncateForEmbedding(text, maxChars) {
  if (typeof maxChars !== 'number' || maxChars <= 0) {
    return text;
  }
  if (text.length <= maxChars) {
    return text;
  }
  return text.slice(0, maxChars);
}

export function readJsonl(relativePath) {
  const target = path.resolve(ROOT, relativePath);
  if (!fs.existsSync(target)) {
    return [];
  }
  return fs.readFileSync(target, 'utf8').split('\n').filter(Boolean).map((line) => JSON.parse(line));
}

export function appendJsonl(relativePath, rows) {
  const target = path.resolve(ROOT, relativePath);
  fs.mkdirSync(path.dirname(target), { recursive: true });
  fs.appendFileSync(target, rows.map((row) => JSON.stringify(row)).join('\n') + '\n', 'utf8');
}

export function writeJsonl(relativePath, rows) {
  const target = path.resolve(ROOT, relativePath);
  fs.mkdirSync(path.dirname(target), { recursive: true });
  fs.writeFileSync(target, rows.map((row) => JSON.stringify(row)).join('\n') + (rows.length > 0 ? '\n' : ''), 'utf8');
}
