import { aH as Color, aI as _ } from './mermaid.core-9eb75b2e.js';

/* IMPORT */
/* MAIN */
//SOURCE: https://planetcalc.com/7779
const luminance = (color) => {
    const { r, g, b } = Color.parse(color);
    const luminance = .2126 * _.channel.toLinear(r) + .7152 * _.channel.toLinear(g) + .0722 * _.channel.toLinear(b);
    return _.lang.round(luminance);
};
/* EXPORT */
var luminance$1 = luminance;

/* IMPORT */
/* MAIN */
const isLight = (color) => {
    return luminance$1(color) >= .5;
};
/* EXPORT */
var isLight$1 = isLight;

/* IMPORT */
/* MAIN */
const isDark = (color) => {
    return !isLight$1(color);
};
/* EXPORT */
var isDark$1 = isDark;

export { isDark$1 as i };
