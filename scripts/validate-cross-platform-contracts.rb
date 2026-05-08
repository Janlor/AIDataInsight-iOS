#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "yaml"
require "set"

ROOT = File.expand_path("..", __dir__)
CONTRACTS_DIR = File.join(ROOT, "docs/cross-platform/contracts")
IOS_FUNCTION_NAME_PATH = File.join(
  ROOT,
  "app-ios/Packages/module-ai/Sources/ModuleAI/Domain/AIChat/FunctionName.swift"
)

class ContractFailure < StandardError; end

def read_json(path)
  JSON.parse(File.read(path))
rescue JSON::ParserError => e
  raise ContractFailure, "Invalid JSON: #{relative(path)}: #{e.message}"
end

def read_yaml(path)
  YAML.load_file(path)
rescue Psych::SyntaxError => e
  raise ContractFailure, "Invalid YAML: #{relative(path)}: #{e.message}"
end

def relative(path)
  path.sub("#{ROOT}/", "")
end

def assert(condition, message)
  raise ContractFailure, message unless condition
end

def assert_equal(expected, actual, message)
  return if expected == actual

  raise ContractFailure, "#{message}\n  expected: #{expected.inspect}\n  actual:   #{actual.inspect}"
end

def load_contracts
  {
    ai_chat_schema: read_json(File.join(CONTRACTS_DIR, "domain/ai-chat.schema.json")),
    ai_chat_usecases: read_yaml(File.join(CONTRACTS_DIR, "usecases/ai-chat.usecases.yaml")),
    openapi: read_yaml(File.join(CONTRACTS_DIR, "api/openapi.yaml")),
    tokens: read_json(File.join(CONTRACTS_DIR, "design/tokens.json"))
  }
end

def validate_parseability
  Dir.glob(File.join(CONTRACTS_DIR, "**/*.{json,yaml}")).sort.each do |path|
    path.end_with?(".json") ? read_json(path) : read_yaml(path)
  end
end

def function_names_from_schema(schema)
  schema.fetch("$defs").fetch("FunctionName").fetch("enum")
end

def function_names_from_ios
  source = File.read(IOS_FUNCTION_NAME_PATH)
  source.scan(/static let \w+\s*=\s*FunctionName\(rawValue:\s*"([^"]+)"\)!/).flatten
end

def dynamic_groups(usecases)
  usecases.fetch("dynamicFunctionContract").fetch("argumentKindByFunctionName")
end

def function_kind_map(usecases)
  dynamic_groups(usecases).each_with_object({}) do |(kind, names), result|
    names.each do |name|
      assert(!result.key?(name), "Duplicate function name in dynamicFunctionContract: #{name}")
      result[name] = kind
    end
  end
end

def validate_function_name_alignment(schema, usecases)
  schema_names = function_names_from_schema(schema).sort
  ios_names = function_names_from_ios.sort
  contract_names = dynamic_groups(usecases).values.flatten.sort

  assert_equal(schema_names, contract_names, "FunctionName schema and dynamicFunctionContract must match")
  assert_equal(schema_names, ios_names, "FunctionName schema and iOS FunctionName.swift must match")
end

def expected_intent_for(kind, arguments)
  return "time" if kind == "timeRange" && arguments["startDate"].nil?
  return "index" if kind == "performanceType"

  nil
end

def validate_function_response_fixture(path, fixture, kind_map)
  data = fixture.fetch("response").fetch("data")
  name = data["name"]
  expected = fixture.fetch("expected")

  assert(kind_map.key?(name), "#{relative(path)} references unknown function name #{name.inspect}")
  kind = kind_map.fetch(name)
  assert_equal(kind, expected.fetch("argumentsKind"), "#{relative(path)} argumentsKind must match function name")

  arguments = data["arguments"] || {}
  expected_intent = expected_intent_for(kind, arguments)
  output = expected.fetch("useCaseOutput")

  if expected_intent
    assert_equal("intent", output.fetch("kind"), "#{relative(path)} should produce an intent")
    assert_equal(expected_intent, output.fetch("type"), "#{relative(path)} intent type mismatch")
  else
    assert_equal("chartRequest", output.fetch("kind"), "#{relative(path)} should produce a chartRequest")
    assert_equal(name, output.fetch("name"), "#{relative(path)} chartRequest name mismatch")
    assert_equal(data.fetch("historyId"), output.fetch("historyId"), "#{relative(path)} chartRequest historyId mismatch")
  end
end

def chart_unit(function_name)
  %w[queryStockGroupByOrg queryStockGroupByWarehouse].include?(function_name) ? "ton" : "currency"
end

def validate_chart_fixture(path, fixture, kind_map)
  request = fixture.fetch("request")
  response_data = fixture.fetch("response").fetch("data")
  expected_payload = fixture.fetch("expected").fetch("chartPayload")
  function_name = response_data.fetch("funcType")

  assert(kind_map.key?(function_name), "#{relative(path)} references unknown chart function #{function_name.inspect}")
  assert_equal("/chart/#{function_name}", request.fetch("path"), "#{relative(path)} chart request path mismatch")
  assert(request.fetch("parameters").key?("historyId"), "#{relative(path)} chart request must include historyId")
  assert_equal(function_name, expected_payload.fetch("functionName"), "#{relative(path)} payload functionName mismatch")
  assert_equal(chart_unit(function_name), expected_payload.fetch("unit"), "#{relative(path)} chart unit mismatch")

  common = response_data["chartCommonVoList"]
  if common && !common.empty?
    expected_series = common.map do |item|
      {
        "xAxis" => item["name"],
        "labels" => [item["name"]],
        "values" => [item["value"] || 0]
      }
    end
    assert_equal(expected_series, expected_payload.fetch("series"), "#{relative(path)} chartCommonVoList series mismatch")
  end
end

def feedback_from_like(value)
  case value
  when "1" then "liked"
  when "0" then "disliked"
  when nil then nil
  else "unknown"
  end
end

def validate_history_fixture(path, fixture)
  details = fixture.fetch("response").fetch("data").fetch("detailList")
  expected_messages = fixture.fetch("expected").fetch("messages")
  assert_equal(details.length, expected_messages.length, "#{relative(path)} expected message count mismatch")

  details.zip(expected_messages).each do |detail, expected|
    case detail.fetch("type")
    when "1"
      assert_equal("user", expected.fetch("role"), "#{relative(path)} question detail should map to user")
      assert_equal("text", expected.fetch("contentKind"), "#{relative(path)} question detail should map to text")
      assert_equal(detail.fetch("content"), expected.fetch("text"), "#{relative(path)} question text mismatch")
    when "2"
      assert_equal("assistant", expected.fetch("role"), "#{relative(path)} answer detail should map to assistant")
      expected_feedback = feedback_from_like(detail["isLike"])
      assert_equal(expected_feedback, expected["feedback"], "#{relative(path)} feedback mismatch") if expected.key?("feedback")

      next unless detail.fetch("contentType") == "2"

      content = read_inline_json(detail.fetch("content"), path)
      expected_payload = expected["chartPayload"]
      assert(expected_payload, "#{relative(path)} chart detail must include expected chartPayload")
      assert_equal(content["funcType"], expected.fetch("functionName"), "#{relative(path)} history chart function mismatch")
      assert_equal(false, expected_payload["seriesCount"].nil?, "#{relative(path)} chartPayload must include seriesCount")
    end
  end
end

def read_inline_json(content, path)
  JSON.parse(content)
rescue JSON::ParserError => e
  raise ContractFailure, "Invalid embedded JSON in #{relative(path)}: #{e.message}"
end

def validate_api_fixture(path, fixture)
  code = fixture.fetch("response").fetch("code")
  expected = fixture.fetch("expected")
  assert_equal(code, expected.fetch("code"), "#{relative(path)} expected code mismatch")

  expected_action = case code
                    when 401 then "clearSessionAndTriggerReauth"
                    when 402 then "refreshTokenThenRetryOriginalRequestOnce"
                    else nil
                    end
  assert_equal(expected_action, expected.fetch("action"), "#{relative(path)} session action mismatch")
end

def validate_fixtures(kind_map)
  Dir.glob(File.join(CONTRACTS_DIR, "fixtures/function-response/*.json")).sort.each do |path|
    fixture = read_json(path)
    if fixture.key?("request") && fixture.fetch("request").fetch("path").start_with?("/chart/")
      validate_chart_fixture(path, fixture, kind_map)
    else
      validate_function_response_fixture(path, fixture, kind_map)
    end
  end

  Dir.glob(File.join(CONTRACTS_DIR, "fixtures/history/*.json")).sort.each do |path|
    validate_history_fixture(path, read_json(path))
  end

  Dir.glob(File.join(CONTRACTS_DIR, "fixtures/api/*.json")).sort.each do |path|
    validate_api_fixture(path, read_json(path))
  end
end

begin
  contracts = load_contracts
  validate_parseability
  validate_function_name_alignment(contracts.fetch(:ai_chat_schema), contracts.fetch(:ai_chat_usecases))
  validate_fixtures(function_kind_map(contracts.fetch(:ai_chat_usecases)))
  puts "Cross-platform contract validation passed."
rescue ContractFailure => e
  warn "Cross-platform contract validation failed:"
  warn e.message
  exit 1
end

