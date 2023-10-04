import { X as Selection, Y as root, Z as array } from './mermaid.core-9eb75b2e.js';

function selectAll(selector) {
  return typeof selector === "string"
      ? new Selection([document.querySelectorAll(selector)], [document.documentElement])
      : new Selection([array(selector)], root);
}

export { selectAll as s };
