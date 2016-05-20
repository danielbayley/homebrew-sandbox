import assert from "node:assert/strict"
import { describe, it } from "node:test"

describe("test", () => {
  it("pass", () => assert.equal(true,  true))
  it("fail", () => assert.equal(false, true))
})
