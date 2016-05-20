import { readFile } from "node:fs/promises"

const content = await readFile(`${import.meta.dirname}/package.json`, "utf8")
const { name, version } = JSON.parse(content)

console.log(name, version)
