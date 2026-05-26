import { NodeCompiler } from '@myriaddreamin/typst-ts-node-compiler';
import path from 'path';
import fs from 'fs';

const source = process.argv[2];
const target_path = process.argv[3];

const $typst = NodeCompiler.create({
    workspace: path.resolve(source, '..'),
    fontArgs: []
});

for(const theme of ['light', 'dark']) {
    const svg = await $typst.svg({
        mainFilePath: path.resolve(source),
        inputs: {
            "theme": theme
        },
        
    });
    fs.writeFileSync(path.resolve(target_path, `${theme}.svg`), svg);
}
