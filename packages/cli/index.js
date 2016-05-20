import {parseArgs} from "node:util"

const options = {
  version: {
    description: "Print `name` and `version`.",
    type: "string",
    short: "v",
  },
}

export default () => parseArgs({ allowPositionals: true, options })
