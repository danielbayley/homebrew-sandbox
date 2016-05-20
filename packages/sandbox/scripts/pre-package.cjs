const fs = require("node:fs")

const encoding = "utf8"
const indent = parseInt(process.env.TABSIZE) || 2

process.chdir(`${__dirname}/..`)
try {
  const content = fs.readFileSync("package.yaml", {encoding})
  const {parse} = require("yaml")
  const js = parse(content, { merge: true })
  const json = JSON.stringify(js, null, indent)
  fs.writeFileSync("package.json", json)
} catch(error) {}
