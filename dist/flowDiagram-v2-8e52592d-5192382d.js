import { p as parser$1, f as flowDb } from './flowDb-52e24d17-d0fc2068.js';
import { f as flowRendererV2, g as flowStyles } from './styles-26373982-0cf6af14.js';
import { u as setConfig } from './mermaid.core-9eb75b2e.js';
import './layout-10435576.js';
import './createText-1f5f8f92-150c30d3.js';
import './index-5219d011-2ceec11f.js';
import './edges-2e77835f-4e798086.js';
import './svgDraw-2526cba0-4dfcc0d9.js';
import './line-660ba903.js';
import './array-72ffbca2.js';
import './path-6ca35b3e.js';
import './selectAll-ea0eb9b2.js';

const diagram = {
  parser: parser$1,
  db: flowDb,
  renderer: flowRendererV2,
  styles: flowStyles,
  init: (cnf) => {
    if (!cnf.flowchart) {
      cnf.flowchart = {};
    }
    cnf.flowchart.arrowMarkerAbsolute = cnf.arrowMarkerAbsolute;
    setConfig({ flowchart: { arrowMarkerAbsolute: cnf.arrowMarkerAbsolute } });
    flowRendererV2.setConf(cnf.flowchart);
    flowDb.clear();
    flowDb.setGen("gen-2");
  }
};

export { diagram };
