import { moScripts, runMoScripts } from './moscript';
import './moscripts.usecases';

// Simple CLI runner for MoScripts
// Usage: ts-node moscript.runner.ts <trigger> '{"inputName": value, ...}'

const [,, trigger, inputJson] = process.argv;
if (!trigger) {
  console.error('Usage: ts-node moscript.runner.ts <trigger> <inputs as JSON>');
  process.exit(1);
}

let inputs: Record<string, any> = {};
try {
  if (inputJson) inputs = JSON.parse(inputJson);
} catch (e) {
  console.error('Invalid JSON for inputs.');
  process.exit(1);
}

const results = runMoScripts(trigger, inputs);
if (results.length === 0) {
  console.log(`No MoScripts registered for trigger: ${trigger}`);
} else {
  results.forEach(({ script, result, voiceLine }, idx) => {
    console.log(`--- MoScript: ${script.name} [${script.id}] ---`);
    console.log('Result:', JSON.stringify(result, null, 2));
    if (voiceLine) console.log('Voice Line:', voiceLine);
    if (script.sass) console.log('(Sass mode enabled)');
    console.log();
  });
}
