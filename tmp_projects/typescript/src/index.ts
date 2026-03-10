import { greet } from './util';
import { foo } from './foo';

export function add(a: number, b: number): number {
  return a + b;
}

console.log(greet('World'));
console.log(foo('World'));
