describe("History Flag Parsing", function()
  local args_parser = require("codediff.core.args")
  local flag_spec = { ["--reverse"] = { short = "-r", type = "boolean" } }

  it("parses --reverse with no positional args", function()
    local positional, flags = args_parser.parse_args({ "--reverse" }, flag_spec)
    assert.are.same({}, positional)
    assert.are.same({ reverse = true }, flags)
  end)

  it("parses --reverse after range", function()
    local positional, flags = args_parser.parse_args({ "HEAD~10", "--reverse" }, flag_spec)
    assert.are.same({ "HEAD~10" }, positional)
    assert.are.same({ reverse = true }, flags)
  end)

  it("parses -r (short form)", function()
    local positional, flags = args_parser.parse_args({ "origin/main..HEAD", "-r" }, flag_spec)
    assert.are.same({ "origin/main..HEAD" }, positional)
    assert.are.same({ reverse = true }, flags)
  end)

  it("parses --reverse with range and file", function()
    local positional, flags = args_parser.parse_args({ "HEAD~20", "%", "--reverse" }, flag_spec)
    assert.are.same({ "HEAD~20", "%" }, positional)
    assert.are.same({ reverse = true }, flags)
  end)

  it("returns error for unknown flag", function()
    local positional, flags, err = args_parser.parse_args({ "--invalid" }, flag_spec)
    assert.is_nil(positional)
    assert.is_nil(flags)
    assert.matches("Unknown flag", err)
  end)

  it("handles no flags gracefully", function()
    local positional, flags = args_parser.parse_args({ "HEAD~10", "%" }, flag_spec)
    assert.are.same({ "HEAD~10", "%" }, positional)
    assert.are.same({}, flags)
  end)

  it("handles empty args", function()
    local positional, flags = args_parser.parse_args({}, flag_spec)
    assert.are.same({}, positional)
    assert.are.same({}, flags)
  end)

  it("handles multiple flags", function()
    local multi_spec = {
      ["--reverse"] = { short = "-r", type = "boolean" },
      ["--limit"] = { short = "-n", type = "string" },
    }
    local positional, flags = args_parser.parse_args({ "HEAD~10", "--reverse", "--limit", "50" }, multi_spec)
    assert.are.same({ "HEAD~10" }, positional)
    assert.are.same({ reverse = true, limit = "50" }, flags)
  end)

  it("returns error for string flag without value", function()
    local string_spec = {
      ["--author"] = { short = "-a", type = "string" },
    }
    local positional, flags, err = args_parser.parse_args({ "--author" }, string_spec)
    assert.is_nil(positional)
    assert.is_nil(flags)
    assert.matches("requires a value", err)
  end)
end)

describe("History --base Flag Parsing", function()
  local args_parser = require("codediff.core.args")
  local flag_spec = {
    ["--reverse"] = { short = "-r", type = "boolean" },
    ["--base"] = { short = "-b", type = "string" },
  }

  it("parses --base with space syntax", function()
    local positional, flags = args_parser.parse_args({ "--base", "WORKING" }, flag_spec)
    assert.are.same({}, positional)
    assert.are.same({ base = "WORKING" }, flags)
  end)

  it("parses -b short form", function()
    local positional, flags = args_parser.parse_args({ "-b", "HEAD" }, flag_spec)
    assert.are.same({}, positional)
    assert.are.same({ base = "HEAD" }, flags)
  end)

  it("parses --base combined with --reverse", function()
    local positional, flags = args_parser.parse_args({ "--base", "HEAD", "--reverse" }, flag_spec)
    assert.are.same({}, positional)
    assert.are.same({ base = "HEAD", reverse = true }, flags)
  end)

  it("parses --base with positional args", function()
    local positional, flags = args_parser.parse_args({ "HEAD~10", "--base", "WORKING", "%" }, flag_spec)
    assert.are.same({ "HEAD~10", "%" }, positional)
    assert.are.same({ base = "WORKING" }, flags)
  end)

  it("returns error for --base without value", function()
    local positional, flags, err = args_parser.parse_args({ "--base" }, flag_spec)
    assert.is_nil(positional)
    assert.is_nil(flags)
    assert.matches("requires a value", err)
  end)

  it("parses --base with branch name", function()
    local positional, flags = args_parser.parse_args({ "--base", "main" }, flag_spec)
    assert.are.same({}, positional)
    assert.are.same({ base = "main" }, flags)
  end)
end)
