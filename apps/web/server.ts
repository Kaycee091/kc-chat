import { readFileSync } from 'fs';
import { join } from 'path';

const htmlContent = readFileSync(join(import.meta.dir, 'index.html'), 'utf-8');

Bun.serve({
  port: 5000,
  fetch(req) {
    return new Response(htmlContent, {
      headers: { 'Content-Type': 'text/html; charset=utf-8' },
    });
  },
});

console.log('Server running on port 5000');
