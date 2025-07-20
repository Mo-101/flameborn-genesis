// MoScript core type and runner interface
export type MoScript = {
  id: string;
  name: string;
  trigger: string; // What event/context it responds to
  inputs: string[];
  logic: (inputs: Record<string, any>) => any;
  voiceLine?: (result: any) => string;
  sass?: boolean;
};

// MoScript registry for dynamic loading
export const moScripts: MoScript[] = [];

export function registerMoScript(script: MoScript) {
  moScripts.push(script);
}

// MoScript runner: executes scripts by trigger and passes inputs
export function runMoScripts(trigger: string, inputs: Record<string, any>): { script: MoScript; result: any; voiceLine?: string }[] {
  return moScripts
    .filter(script => script.trigger === trigger)
    .map(script => {
      const result = script.logic(inputs);
      const voiceLine = script.voiceLine ? script.voiceLine(result) : undefined;
      return { script, result, voiceLine };
    });
}
