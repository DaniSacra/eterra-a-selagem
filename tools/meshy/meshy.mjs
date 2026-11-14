// Meshy pipeline for the game's models, one step at a time so each step can be checked before spending credits.
//
//   node tools/meshy/meshy.mjs balance
//   node tools/meshy/meshy.mjs preview <key>   mesh only (meshy-t2.5: 5 credits), saves <key>-preview.png
//   node tools/meshy/meshy.mjs refine <key>    texture (10 credits), saves <key>.glb and <key>.png
//   node tools/meshy/meshy.mjs rig <key>       skeleton + walk/run (5 credits), saves <key>-rigged.glb, -walk.glb, -run.glb
//
// Prompts live in tools/meshy/prompts.json; task ids and credits in tools/meshy/tasks.json.
// Files go to assets/models/meshy/<key>/. The API key comes from MESHY_API_KEY or the Jerusalem project's
// .env.local; it is never printed or written.
import { readFileSync, writeFileSync, existsSync, mkdirSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const ROOT = join(here, '..', '..');
const API = 'https://api.meshy.ai/openapi';
const TASKS = join(here, 'tasks.json');
const ENV = '/home/dani/projects/jerusalem-antiga/.env.local';

function apiKey() {
  if (process.env.MESHY_API_KEY) return process.env.MESHY_API_KEY.trim();
  const line = readFileSync(ENV, 'utf8').split('\n').find((l) => l.startsWith('MESHY_API_KEY='));
  if (!line) throw new Error('MESHY_API_KEY missing');
  return line.slice('MESHY_API_KEY='.length).trim().replace(/^["']|["']$/g, '');
}
const KEY = apiKey();

async function call(method, path, body) {
  const res = await fetch(API + path, {
    method,
    headers: { Authorization: `Bearer ${KEY}`, 'Content-Type': 'application/json' },
    body: body ? JSON.stringify(body) : undefined,
  });
  const text = await res.text();
  if (!res.ok) throw new Error(`${method} ${path} -> ${res.status} ${text.slice(0, 300)}`);
  return text ? JSON.parse(text) : null;
}

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
async function wait(path, label) {
  for (;;) {
    const t = await call('GET', path);
    if (t.status === 'SUCCEEDED') return t;
    if (t.status === 'FAILED' || t.status === 'CANCELED') throw new Error(`${label} ${t.status}: ${JSON.stringify(t.task_error)}`);
    await sleep(8000);
  }
}

const loadTasks = () => (existsSync(TASKS) ? JSON.parse(readFileSync(TASKS, 'utf8')) : {});
function saveTask(key, data) {
  const all = loadTasks();
  all[key] = { ...(all[key] ?? {}), ...data };
  writeFileSync(TASKS, JSON.stringify(all, null, 2) + '\n');
}

async function download(url, file) {
  const buf = Buffer.from(await (await fetch(url)).arrayBuffer());
  writeFileSync(file, buf);
  return buf.length;
}

function outDir(key) {
  const dir = join(ROOT, 'assets', 'models', 'meshy', key);
  mkdirSync(dir, { recursive: true });
  return dir;
}

async function preview(key) {
  const { style, models } = JSON.parse(readFileSync(join(here, 'prompts.json'), 'utf8'));
  const spec = models[key];
  if (!spec) throw new Error(`no prompt for ${key}`);
  // a model may carry its own style (the shared one names a crimson accent)
  const prompt = `${spec.prompt} ${spec.style ?? style}`;
  if (prompt.length > 800) throw new Error(`${key}: prompt has ${prompt.length} chars`);
  const body = {
    mode: 'preview', prompt, model_type: 'smart-topology', ai_model: 'meshy-t2.5',
    target_polycount: spec.polycount, topology: 'triangle', target_formats: ['glb'],
  };
  if (spec.pose) body.pose_mode = spec.pose;
  const id = (await call('POST', '/v2/text-to-3d', body)).result;
  saveTask(key, { prompt, polycount: spec.polycount, previewId: id, attempt: (loadTasks()[key]?.attempt ?? 0) + 1 });
  console.log(`${key}: preview ${id}`);
  const t = await wait(`/v2/text-to-3d/${id}`, `${key} preview`);
  if (t.thumbnail_url) await download(t.thumbnail_url, join(outDir(key), `${key}-preview.png`));
  saveTask(key, { previewCredits: t.consumed_credits });
  console.log(`${key}: preview done (${t.consumed_credits} credits)`);
}

async function refine(key) {
  const task = loadTasks()[key];
  const id = (await call('POST', '/v2/text-to-3d', {
    mode: 'refine', preview_task_id: task.previewId, texture_resolution: '2k', enable_pbr: false, target_formats: ['glb'],
  })).result;
  saveTask(key, { refineId: id });
  console.log(`${key}: refine ${id}`);
  const t = await wait(`/v2/text-to-3d/${id}`, `${key} refine`);
  const dir = outDir(key);
  const bytes = await download(t.model_urls.glb, join(dir, `${key}.glb`));
  if (t.thumbnail_url) await download(t.thumbnail_url, join(dir, `${key}.png`));
  saveTask(key, { refineCredits: t.consumed_credits, bytes });
  console.log(`${key}: refine done (${t.consumed_credits} credits, ${bytes} bytes)`);
}

async function rig(key) {
  const task = loadTasks()[key];
  const id = (await call('POST', '/v1/rigging', { input_task_id: task.refineId, height_meters: 1.8 })).result;
  saveTask(key, { rigId: id });
  console.log(`${key}: rig ${id}`);
  const t = await wait(`/v1/rigging/${id}`, `${key} rig`);
  const dir = outDir(key);
  const r = t.result;
  await download(r.rigged_character_glb_url, join(dir, `${key}-rigged.glb`));
  if (r.basic_animations) {
    await download(r.basic_animations.walking_glb_url, join(dir, `${key}-walk.glb`));
    await download(r.basic_animations.running_glb_url, join(dir, `${key}-run.glb`));
  }
  saveTask(key, { rigCredits: t.consumed_credits });
  console.log(`${key}: rig done (${t.consumed_credits} credits)`);
}

const [cmd, key] = process.argv.slice(2);
const steps = { preview, refine, rig };
if (cmd === 'balance') console.log((await call('GET', '/v1/balance')).balance);
else if (steps[cmd] && key) await steps[cmd](key);
else console.log('usage: balance | preview <key> | refine <key> | rig <key>');
