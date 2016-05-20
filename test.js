import assert from "node:assert/strict"
import { describe, it } from "node:test"

describe("test", () => {
  it("passes", () => assert.equal(true, true))
  it("fails",  () => assert.equal(true, false))
})
