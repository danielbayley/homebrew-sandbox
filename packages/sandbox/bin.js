#! /usr/bin/env node
import parse from "cli"
import { name, version } from "./index.js"

const { values  } = parse()
const { version } = values

if (version) console.log(`${name} v${version}`) ?? exit(0)
