import fs from "node:fs/promises"

const {dirname} = import.meta
const metadata  = await fs.readFile(`${dirname}/package.json`, new TextDecoder)

export const { name, version } = JSON.parse(metadata)
