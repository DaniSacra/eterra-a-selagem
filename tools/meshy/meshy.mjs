// Meshy pipeline for the game's models, one step at a time so each step can be checked before spending credits.
//
//   node tools/meshy/meshy.mjs balance
//   node tools/meshy/meshy.mjs preview <key>   mesh only (meshy-t2.5: 5 credits), saves <key>-preview.png
//   node tools/meshy/meshy.mjs refine <key>    texture (10 credits), saves <key>.glb and <key>.png
//   node tools/meshy/meshy.mjs image <key> [--dry]   image(s) to 3D with texture (30 credits on latest; checks the
//                                              balance first; --dry only prints the request), saves <key>.glb and <key>.png
//   node tools/meshy/meshy.mjs retexture <key> [--dry]  new texture on the same mesh from models[key].retexture (10)
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

// Image to 3D from approved concept art: models[key].images (first = front view; up to 4 go to multi-image).
// Credits per the Meshy pricing page (2026-11-14): meshy-7.1/latest/meshy-6 = 30 with a 2K texture, meshy-6-lite = 15.
const IMAGE_COST = { latest: 30, 'meshy-7.1': 30, 'meshy-6': 30, 'meshy-6-lite': 15 };
const dataUri = (file) => `data:image/png;base64,${readFileSync(join(ROOT, file)).toString('base64')}`;

async function image(key, dry) {
  const spec = JSON.parse(readFileSync(join(here, 'prompts.json'), 'utf8')).models[key];
  if (!spec?.images?.length) throw new Error(`no images for ${key}`);
  const ai = spec.ai_model ?? 'latest';
  const multi = spec.images.length > 1;
  const body = {
    ai_model: ai, should_texture: true, texture_resolution: '2k', enable_pbr: false, target_formats: ['glb'],
    should_remesh: true, topology: 'triangle', target_polycount: spec.polycount ?? 30000,
  };
  if (spec.pose) body.pose_mode = spec.pose;
  if (spec.texture_prompt) body.texture_prompt = spec.texture_prompt;
  const cost = IMAGE_COST[ai];
  const balance = (await call('GET', '/v1/balance')).balance;
  console.log(`${key}: ${multi ? 'multi-image' : 'image'} to 3D, ${ai}, ${spec.images.length} image(s), about ${cost} credits; balance ${balance}`);
  console.log(JSON.stringify(body));
  if (dry) return;
  if (cost === undefined || balance < cost) throw new Error(`not enough credits (${balance} < ${cost}); nothing was sent`);
  const images = spec.images.map(dataUri);
  if (multi) body.image_urls = images; else body.image_url = images[0];
  const path = multi ? '/v1/multi-image-to-3d' : '/v1/image-to-3d';
  const id = (await call('POST', path, body)).result;
  saveTask(key, { mode: path.slice(4), images: spec.images, ai_model: ai, imageId: id, attempt: (loadTasks()[key]?.attempt ?? 0) + 1 });
  console.log(`${key}: ${id}`);
  const t = await wait(`${path}/${id}`, `${key} image`);
  const dir = outDir(key);
  const bytes = await download(t.model_urls.glb, join(dir, `${key}.glb`));
  if (t.thumbnail_url) await download(t.thumbnail_url, join(dir, `${key}.png`));
  saveTask(key, { imageCredits: t.consumed_credits, bytes });
  console.log(`${key}: done (${t.consumed_credits} credits, ${bytes} bytes)`);
}

// Repaints the texture of a model already made (same mesh and UVs), from a text prompt: models[key].retexture.
// About 10 credits. The first texture is kept as <key>-v1.glb / -v1.png; the new one becomes <key>.glb.
async function retexture(key, dry) {
  const spec = JSON.parse(readFileSync(join(here, 'prompts.json'), 'utf8')).models[key];
  const task = loadTasks()[key];
  const source = task.retextureId ?? task.imageId ?? task.refineId;
  if (!spec?.retexture || !source) throw new Error(`no retexture prompt or no model for ${key}`);
  const body = { input_task_id: source, text_style_prompt: spec.retexture, enable_original_uv: true, enable_pbr: false };
  const balance = (await call('GET', '/v1/balance')).balance;
  console.log(`${key}: retexture, about 10 credits; balance ${balance}`);
  console.log(JSON.stringify(body));
  if (dry) return;
  if (balance < 10) throw new Error(`not enough credits (${balance}); nothing was sent`);
  const dir = outDir(key);
  const n = (task.retextures ?? 0) + 1;
  for (const ext of ['glb', 'png'])
    if (existsSync(join(dir, `${key}.${ext}`))) writeFileSync(join(dir, `${key}-v${n}.${ext}`), readFileSync(join(dir, `${key}.${ext}`)));
  const id = (await call('POST', '/v1/retexture', body)).result;
  saveTask(key, { retextureId: id, retextures: n, retexturePrompt: spec.retexture });
  console.log(`${key}: retexture ${id}`);
  const t = await wait(`/v1/retexture/${id}`, `${key} retexture`);
  const bytes = await download(t.model_urls.glb, join(dir, `${key}.glb`));
  if (t.thumbnail_url) await download(t.thumbnail_url, join(dir, `${key}.png`));
  saveTask(key, { retextureCredits: t.consumed_credits, bytes });
  console.log(`${key}: retexture done (${t.consumed_credits} credits, ${bytes} bytes)`);
}

async function rig(key) {
  const task = loadTasks()[key];
  const source = task.retextureId ?? task.imageId ?? task.refineId;
  const id = (await call('POST', '/v1/rigging', { input_task_id: source, height_meters: 1.8 })).result;
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

const [cmd, key, flag] = process.argv.slice(2);
const steps = { preview, refine, rig, image, retexture };
if (cmd === 'balance') console.log((await call('GET', '/v1/balance')).balance);
else if (steps[cmd] && key) await steps[cmd](key, flag === '--dry');
else console.log('usage: balance | preview <key> | refine <key> | image <key> [--dry] | retexture <key> [--dry] | rig <key>');
