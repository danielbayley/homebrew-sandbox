import fs from "node:fs/promises"

const indent  = parseInt(process.env.TABSIZE) || 2
const include = [
  "version",
  "name",
  "description",
  "keywords",
  "homepage",
  "repository",
  "bugs",
  "author",
  "license",
  "type",
  "exports",
  "engines",
  "packageManager",
  "dependencies",
  "peerDependencies",
  "peerDependenciesMeta",
  "optionalDependencies",
  "scripts",
  "scripts.postinstall",
  "scripts.uninstall",
]

const bump = async (version = "0.0.0", level = "patch") => import("semver")
  .then(semver => semver.inc(version,  level))

function isEmpty(value) {
  if (value?.constructor === Object) value = Object.keys(value)
  return value.length === 0
}

const filter = (metadata, prefix = "") => Object
  .entries(metadata)
  .reduce((metadata, [key, value]) => {
    if (key === "scripts") value = filter(value, "scripts.")
    if (include.includes(prefix + key) && !isEmpty(value)) metadata[key] = value
    return metadata
  }, {})

const {npm_new_version} = process.env
const [level] = process.argv.slice(2)

let match, content
if (process.stdin.isTTY) {
  [match] = await Array.fromAsync(fs.glob("package.{yaml,json}"))
  if (match == null) throw "No package.* found"

  content = await fs.readFile(match, { encoding: "utf8" })
} else {
  const {createInterface} = await import("node:readline")
  const stdin = createInterface({ input: process.stdin })
  const lines = await Array.fromAsync(stdin)
  content = lines.join("\n")
}

let   metadata
try { metadata = await JSON.parse(content) } catch(error) {}

if (metadata == null) {
  const {parseDocument} = await import("yaml")
  const doc = parseDocument(content, { merge: true })
  metadata  = doc.toJS()

  metadata.version = npm_new_version ?? await bump(metadata.version, level)
  doc.set("version", metadata.version)

  // https://eemeli.org/yaml#tostring-options
  const options = {
    indent,
    indentSeq: false,
    flowCollectionPadding: false,
  }

  const yaml = doc.toString(options)
  process.stdin.isTTY ? await fs.writeFile("package.yaml", yaml) : console.log(yaml)

} else {
  metadata.version = npm_new_version ?? await bump(metadata.version, level)

  const json = JSON.stringify(metadata, null, indent)
  process.stdin.isTTY ? await fs.writeFile("package.json", json) : console.log(json)
}

const { files = [], publishConfig } = metadata
const { directory } = publishConfig ?? {}

if (directory) {
  await fs.mkdir(directory, { recursive: true })

  const clean = filter(metadata)
  const json  = JSON.stringify(clean, null, indent)
  await fs.writeFile(`${directory}/package.json`, json)

  await Promise.all(files.map(file => fs.copyFile(file, `${directory}/${file}`)))
}

if (process.stdin.isTTY) {
  const {exec}      = await import("node:child_process")
  const {promisify} = await import("node:util")
  const shell = promisify(exec)

  const {version} = metadata
  const commit = [
    `git add ${match}`,
    `git commit --message ${version}`,
    `git tag  --annotate v${version} -m ""`,
    "git push --follow-tags",
  ]
  const command = commit.join(" && ")
  const { stdout, stderr } = await shell(command)
  const severity = stderr ? "error" : "log"
  console[severity](stderr ?? stdout)
}
