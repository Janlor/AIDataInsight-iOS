#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "rbconfig"
require "time"
require "yaml"

ROOT = File.expand_path("..", __dir__)
CONTRACTS_DIR = File.join(ROOT, "docs/cross-platform/contracts")
ANDROID_OUTPUT = File.join(
  ROOT,
  "app-android/core/model/src/main/java/com/aidatainsight/android/core/model/contract/ContractModels.kt"
)
WEB_OUTPUT = File.join(ROOT, "app-web/src/contracts/generated/models.ts")
HARMONY_OUTPUT = File.join(ROOT, "app-harmony/entry/src/main/ets/contracts/generated/ContractModels.ets")
MANIFEST_OUTPUT = File.join(ROOT, "docs/cross-platform/contracts/generated-manifest.json")

def read_json(path)
  JSON.parse(File.read(path))
end

def read_yaml(path)
  YAML.load_file(path)
end

def pascal_case(value)
  value
    .split(/[^a-zA-Z0-9]+/)
    .flat_map { |part| part.split(/(?=[A-Z])/) }
    .reject(&:empty?)
    .map { |part| part[0].upcase + part[1..] }
    .join
end

def enum_case(value)
  pascal_case(value)
end

def dynamic_function_contract
  read_yaml(File.join(CONTRACTS_DIR, "usecases/ai-chat.usecases.yaml")).fetch("dynamicFunctionContract")
end

def function_names
  read_json(File.join(CONTRACTS_DIR, "domain/ai-chat.schema.json"))
    .fetch("$defs")
    .fetch("FunctionName")
    .fetch("enum")
end

def mock_base_url
  mock_environment_properties
    .fetch("baseUrl")
    .fetch("const")
end

def mock_ai_chat_stream_path
  read_json(File.join(CONTRACTS_DIR, "domain/ai-chat.schema.json"))
    .fetch("$defs")
    .fetch("AIChatEndpoint")
    .fetch("properties")
    .fetch("streamPath")
    .fetch("const")
end

def mock_environment_properties
  read_json(File.join(CONTRACTS_DIR, "domain/environment.schema.json"))
    .fetch("$defs")
    .fetch("MockApiEnvironment")
    .fetch("allOf")
    .last
    .fetch("properties")
end

def kind_by_function_name
  dynamic_function_contract.fetch("argumentKindByFunctionName").each_with_object({}) do |(kind, names), result|
    names.each { |name| result[name] = kind }
  end
end

def generated_header(language)
  case language
  when :kotlin
    "// Generated from docs/cross-platform/contracts. Do not edit by hand.\n"
  when :typescript
    "// Generated from docs/cross-platform/contracts. Do not edit by hand.\n"
  when :arkts
    "// Generated from docs/cross-platform/contracts. Do not edit by hand.\n"
  else
    ""
  end
end

def kotlin_function_enum(names)
  body = names.map do |name|
    "    @SerialName(\"#{name}\")\n    #{enum_case(name)}(\"#{name}\")"
  end.join(",\n")

  <<~KOTLIN
    @Serializable
    enum class FunctionName(val rawValue: String) {
    #{body};

        val argumentKind: FunctionArgumentKind
            get() = when (this) {
    #{names.map { |name| "            #{enum_case(name)} -> FunctionArgumentKind.#{enum_case(kind_by_function_name.fetch(name))}" }.join("\n")}
            }

        companion object {
            fun fromRawValue(rawValue: String): FunctionName? = entries.firstOrNull { it.rawValue == rawValue }
        }
    }
  KOTLIN
end

def kotlin_models
  names = function_names
  <<~KOTLIN
    #{generated_header(:kotlin)}package com.aidatainsight.android.core.model.contract

    import kotlinx.serialization.SerialName
    import kotlinx.serialization.Serializable

    object MockApiEnvironment {
        const val DefaultBaseUrl: String = "#{mock_base_url}"
    }

    object AIChatEndpoint {
        const val StreamPath: String = "#{mock_ai_chat_stream_path}"
    }

    @Serializable
    data class ApiEnvironment(
        val name: String,
        val baseUrl: String,
        val description: String? = null,
    )

    @Serializable
    data class AccountSession(
        val accessToken: String? = null,
        val refreshToken: String? = null,
        val orgId: Int? = null,
        val username: String? = null,
        val isLogin: Boolean = false,
    )

    @Serializable
    data class AccountUser(
        val id: Int? = null,
        val username: String? = null,
        val nickname: String? = null,
        val phone: String? = null,
    )

    @Serializable
    enum class AIHomeDestination {
        Chat,
        History,
        Settings,
    }

    @Serializable
    enum class AIHomePanel {
        None,
        History,
    }

    @Serializable
    data class AIHomeSession(
        val isAuthenticated: Boolean,
        val entryDestination: AIHomeDestination,
        val selectedHistoryId: Int? = null,
        val activePanel: AIHomePanel,
    )

    @Serializable
    enum class AIHomeCommand {
        OpenAIHome,
        OpenHistoryPanel,
        CloseHistoryPanel,
        SelectHistoryConversation,
        StartNewConversation,
        OpenSettings,
        LogoutToLogin,
    }

    @Serializable
    data class SettingAccountInfo(
        val nickname: String? = null,
        val username: String? = null,
        val phone: String? = null,
    )

    @Serializable
    data class SettingCapability(
        val canUpdatePassword: Boolean,
        val canOpenPrivacy: Boolean,
        val canLogout: Boolean,
    )

    @Serializable
    data class SettingSnapshot(
        val accountInfo: SettingAccountInfo,
        val capability: SettingCapability,
        val appVersion: String,
    )

    @Serializable
    enum class HistoryDetailType(val rawValue: String) {
        @SerialName("1")
        Question("1"),

        @SerialName("2")
        Answer("2"),
    }

    @Serializable
    enum class HistoryContentType(val rawValue: String) {
        @SerialName("1")
        Ai("1"),

        @SerialName("2")
        Chart("2"),
    }

    @Serializable
    data class HistoryDetail(
        val id: Int? = null,
        val historyId: Int? = null,
        val type: HistoryDetailType? = null,
        val contentType: HistoryContentType? = null,
        val content: String? = null,
        val isLike: String? = null,
        val createTime: String? = null,
        val updateTime: String? = null,
    )

    @Serializable
    data class HistoryRecord(
        val id: Int? = null,
        val name: String? = null,
        val createId: Int? = null,
        val updateId: Int? = null,
        val createName: String? = null,
        val updateName: String? = null,
        val createTime: String? = null,
        val updateTime: String? = null,
        val detailList: List<HistoryDetail>? = null,
    )

    @Serializable
    data class RecordPage(
        val currentPage: Int? = null,
        val pageSize: Int? = null,
        val total: Int? = null,
        val pages: Int? = null,
        val cacheKey: String? = null,
        val records: List<HistoryRecord>? = null,
    )

    @Serializable
    data class TemplateQuestionSet(
        val questions: List<String> = emptyList(),
    )

    @Serializable
    enum class FunctionArgumentKind {
        Basic,
        TimeRange,
        Warehouse,
        AccountAge,
        PerformanceType,
    }

    #{kotlin_function_enum(names).rstrip}

    @Serializable
    data class BasicQuery(
        val orgId: Int? = null,
        val customerName: String? = null,
        val orderType: String? = null,
        val operator: String? = null,
        val value: Double? = null,
    )

    @Serializable
    data class TimeRangeQuery(
        val startDate: String? = null,
        val endDate: String? = null,
        val orgId: Int? = null,
        val customerName: String? = null,
        val goodsType: Int? = null,
        val orderType: String? = null,
        val operator: String? = null,
        val value: Double? = null,
    )

    @Serializable
    data class WarehouseQuery(
        val orgId: Int? = null,
        val warehouseName: String? = null,
        val goodsType: Int? = null,
        val orderType: String? = null,
        val operator: String? = null,
        val value: Double? = null,
    )

    @Serializable
    data class AccountAgeQuery(
        val orgId: Int? = null,
        val customerName: String? = null,
        val orderType: String? = null,
        val valueArray: List<String>? = null,
    )

    @Serializable
    data class PerformanceTypeQuery(
        val indexType: String? = null,
    )

    @Serializable
    sealed interface FunctionArguments {
        val kind: FunctionArgumentKind

        @Serializable
        data class Basic(val value: BasicQuery) : FunctionArguments {
            override val kind: FunctionArgumentKind = FunctionArgumentKind.Basic
        }

        @Serializable
        data class TimeRange(val value: TimeRangeQuery) : FunctionArguments {
            override val kind: FunctionArgumentKind = FunctionArgumentKind.TimeRange
        }

        @Serializable
        data class Warehouse(val value: WarehouseQuery) : FunctionArguments {
            override val kind: FunctionArgumentKind = FunctionArgumentKind.Warehouse
        }

        @Serializable
        data class AccountAge(val value: AccountAgeQuery) : FunctionArguments {
            override val kind: FunctionArgumentKind = FunctionArgumentKind.AccountAge
        }

        @Serializable
        data class PerformanceType(val value: PerformanceTypeQuery) : FunctionArguments {
            override val kind: FunctionArgumentKind = FunctionArgumentKind.PerformanceType
        }
    }

    @Serializable
    data class FunctionModel(
        val historyId: Int? = null,
        val hasTool: Boolean? = null,
        val name: FunctionName? = null,
        val msg: String? = null,
        val arguments: FunctionArguments? = null,
    )

    @Serializable
    data class ChartCommonItem(
        val bizId: String? = null,
        val name: String? = null,
        val value: Double? = null,
    )

    @Serializable
    data class AccountAgeGroupItem(
        val name: String? = null,
        val valueList: List<Double>? = null,
        val labelList: List<String>? = null,
        val msg: String? = null,
        val chartType: String? = null,
    )

    @Serializable
    data class HistoryChartDetail(
        val funcType: FunctionName? = null,
        val chartCommonVoList: List<ChartCommonItem>? = null,
        val accountAgeGroupVoList: List<AccountAgeGroupItem>? = null,
    )

    @Serializable
    enum class ConversationRole {
        User,
        Assistant,
    }

    @Serializable
    enum class ConversationContentKind {
        Welcome,
        Text,
        Intent,
        Chart,
    }

    @Serializable
    enum class AIChatIntentType {
        Time,
        Index,
    }

    @Serializable
    enum class FeedbackState {
        Liked,
        Disliked,
        None,
        Unknown,
    }

    @Serializable
    enum class ChartUnit {
        Currency,
        Ton,
    }

    @Serializable
    data class ChartSeries(
        val xAxis: String,
        val labels: List<String>,
        val values: List<Double>,
    )

    @Serializable
    data class ChartPayload(
        val functionName: FunctionName? = null,
        val unit: ChartUnit,
        val series: List<ChartSeries>,
        val emptyMessage: String? = null,
    )

    @Serializable
    data class ConversationMessage(
        val id: String,
        val role: ConversationRole,
        val contentKind: ConversationContentKind,
        val text: String? = null,
        val intentType: AIChatIntentType? = null,
        val chartPayload: ChartPayload? = null,
        val feedback: FeedbackState = FeedbackState.None,
        val historyDetailId: Int? = null,
        val functionName: FunctionName? = null,
    )
  KOTLIN
end

def ts_string_union(name, values)
  "export type #{name} =\n#{values.map { |value| "  | '#{value}'" }.join("\n")};"
end

def typescript_models
  names = function_names
  kinds = dynamic_function_contract.fetch("argumentKindByFunctionName")
  kind_entries = kinds.flat_map { |kind, values| values.map { |name| "  #{JSON.generate(name)}: '#{kind}'" } }

  <<~TS
    #{generated_header(:typescript)}
    export const mockApiEnvironment = {
      name: 'mock',
      baseUrl: #{JSON.generate(mock_base_url)},
      description: 'iOS 当前学习项目使用的 Apifox mock host，各端默认开发环境必须与它保持一致。',
    } as const;

    export const aiChatEndpoint = {
      streamPath: #{JSON.generate(mock_ai_chat_stream_path)},
    } as const;

    export interface ApiEnvironment {
      name: 'mock' | 'dev' | 'sit' | 'uat' | 'staging' | 'pre' | 'production';
      baseUrl: string;
      description?: string | null;
    }

    export interface AccountSession {
      accessToken?: string | null;
      refreshToken?: string | null;
      orgId?: number | null;
      username?: string | null;
      isLogin: boolean;
    }

    export interface AccountUser {
      id?: number | null;
      username?: string | null;
      nickname?: string | null;
      phone?: string | null;
    }

    export type AIHomeDestination = 'chat' | 'history' | 'settings';
    export type AIHomePanel = 'none' | 'history';
    export type AIHomeCommand =
      | 'openAIHome'
      | 'openHistoryPanel'
      | 'closeHistoryPanel'
      | 'selectHistoryConversation'
      | 'startNewConversation'
      | 'openSettings'
      | 'logoutToLogin';

    export interface AIHomeSession {
      isAuthenticated: boolean;
      entryDestination: AIHomeDestination;
      selectedHistoryId?: number | null;
      activePanel: AIHomePanel;
    }

    export interface HistoryDetail {
      id?: number | null;
      historyId?: number | null;
      type?: '1' | '2' | null;
      contentType?: '1' | '2' | null;
      content?: string | null;
      isLike?: '1' | '0' | null;
      createTime?: string | null;
      updateTime?: string | null;
    }

    export interface HistoryRecord {
      id?: number | null;
      name?: string | null;
      createId?: number | null;
      updateId?: number | null;
      createName?: string | null;
      updateName?: string | null;
      createTime?: string | null;
      updateTime?: string | null;
      detailList?: HistoryDetail[] | null;
    }

    export interface RecordPage {
      currentPage?: number | null;
      pageSize?: number | null;
      total?: number | null;
      pages?: number | null;
      cacheKey?: string | null;
      records?: HistoryRecord[] | null;
    }

    export interface TemplateQuestionSet {
      questions: string[];
    }

    #{ts_string_union("FunctionName", names)}

    export type FunctionArgumentKind = 'basic' | 'timeRange' | 'warehouse' | 'accountAge' | 'performanceType';

    export const functionArgumentKindByName: Record<FunctionName, FunctionArgumentKind> = {
    #{kind_entries.join(",\n")}
    };

    export interface BasicQuery {
      orgId?: number | null;
      customerName?: string | null;
      orderType?: string | null;
      operator?: string | null;
      value?: number | null;
    }

    export interface TimeRangeQuery extends BasicQuery {
      startDate?: string | null;
      endDate?: string | null;
      goodsType?: number | null;
    }

    export interface WarehouseQuery {
      orgId?: number | null;
      warehouseName?: string | null;
      goodsType?: number | null;
      orderType?: string | null;
      operator?: string | null;
      value?: number | null;
    }

    export interface AccountAgeQuery {
      orgId?: number | null;
      customerName?: string | null;
      orderType?: string | null;
      valueArray?: string[] | null;
    }

    export interface PerformanceTypeQuery {
      indexType?: string | null;
    }

    export type FunctionArguments =
      | { kind: 'basic'; value: BasicQuery }
      | { kind: 'timeRange'; value: TimeRangeQuery }
      | { kind: 'warehouse'; value: WarehouseQuery }
      | { kind: 'accountAge'; value: AccountAgeQuery }
      | { kind: 'performanceType'; value: PerformanceTypeQuery };

    export interface FunctionModel {
      historyId?: number | null;
      hasTool?: boolean | null;
      name?: FunctionName | null;
      msg?: string | null;
      arguments?: FunctionArguments | null;
    }

    export interface ChartCommonItem {
      bizId?: string | null;
      name?: string | null;
      value?: number | null;
    }

    export interface AccountAgeGroupItem {
      name?: string | null;
      valueList?: number[] | null;
      labelList?: string[] | null;
      msg?: string | null;
      chartType?: string | null;
    }

    export interface HistoryChartDetail {
      funcType?: FunctionName | null;
      chartCommonVoList?: ChartCommonItem[] | null;
      accountAgeGroupVoList?: AccountAgeGroupItem[] | null;
    }

    export type ConversationRole = 'user' | 'assistant';
    export type ConversationContentKind = 'welcome' | 'text' | 'intent' | 'chart';
    export type AIChatIntentType = 'time' | 'index';
    export type FeedbackState = 'liked' | 'disliked' | 'none' | 'unknown';
    export type ChartUnit = 'currency' | 'ton';

    export interface ChartSeries {
      xAxis: string;
      labels: string[];
      values: number[];
    }

    export interface ChartPayload {
      functionName?: FunctionName | null;
      unit: ChartUnit;
      series: ChartSeries[];
      emptyMessage?: string | null;
    }

    export interface ConversationMessage {
      id: string;
      role: ConversationRole;
      contentKind: ConversationContentKind;
      text?: string | null;
      intentType?: AIChatIntentType | null;
      chartPayload?: ChartPayload | null;
      feedback: FeedbackState;
      historyDetailId?: number | null;
      functionName?: FunctionName | null;
    }
  TS
end

def arkts_enum(name, values)
  body = values.map { |value| "  #{enum_case(value)} = #{JSON.generate(value)}" }.join(",\n")
  <<~ARKTS
    export enum #{name} {
    #{body}
    }
  ARKTS
end

def arkts_function_argument_kind_switch(names)
  cases = names.map do |name|
    "    case FunctionName.#{enum_case(name)}:\n      return FunctionArgumentKind.#{enum_case(kind_by_function_name.fetch(name))}"
  end.join("\n")

  <<~ARKTS
    export function functionArgumentKindForName(name: FunctionName): FunctionArgumentKind {
      switch (name) {
    #{cases}
        default:
          throw new Error('Unknown FunctionName: ' + name)
      }
    }
  ARKTS
end

def arkts_function_name_from_raw_switch(names)
  cases = names.map do |name|
    "    case #{JSON.generate(name)}:\n      return FunctionName.#{enum_case(name)}"
  end.join("\n")

  <<~ARKTS
    export function functionNameFromRawValue(rawValue?: string | null): FunctionName | null {
      switch (rawValue) {
    #{cases}
        default:
          return null
      }
    }
  ARKTS
end

def arkts_models
  names = function_names

  <<~ARKTS
    #{generated_header(:arkts)}
    export interface ApiEnvironment {
      name: string
      baseUrl: string
      description?: string | null
    }

    export const mockApiEnvironment: ApiEnvironment = {
      name: 'mock',
      baseUrl: #{JSON.generate(mock_base_url)},
      description: 'iOS 当前学习项目使用的 Apifox mock host，各端默认开发环境必须与它保持一致。'
    }

    export interface AIChatEndpointContract {
      streamPath: string
    }

    export const aiChatEndpoint: AIChatEndpointContract = {
      streamPath: #{JSON.generate(mock_ai_chat_stream_path)}
    }

    export interface AccountSession {
      accessToken?: string | null
      refreshToken?: string | null
      orgId?: number | null
      username?: string | null
      isLogin: boolean
    }

    export interface AccountUser {
      id?: number | null
      username?: string | null
      nickname?: string | null
      phone?: string | null
    }

    export enum AIHomeDestination {
      Chat = 'chat',
      History = 'history',
      Settings = 'settings'
    }

    export enum AIHomePanel {
      None = 'none',
      History = 'history'
    }

    export enum AIHomeCommand {
      OpenAIHome = 'openAIHome',
      OpenHistoryPanel = 'openHistoryPanel',
      CloseHistoryPanel = 'closeHistoryPanel',
      SelectHistoryConversation = 'selectHistoryConversation',
      StartNewConversation = 'startNewConversation',
      OpenSettings = 'openSettings',
      LogoutToLogin = 'logoutToLogin'
    }

    export interface AIHomeSession {
      isAuthenticated: boolean
      entryDestination: AIHomeDestination
      selectedHistoryId?: number | null
      activePanel: AIHomePanel
    }

    export enum HistoryDetailType {
      Question = '1',
      Answer = '2'
    }

    export enum HistoryContentType {
      Ai = '1',
      Chart = '2'
    }

    export interface HistoryDetail {
      id?: number | null
      historyId?: number | null
      type?: HistoryDetailType | null
      contentType?: HistoryContentType | null
      content?: string | null
      isLike?: string | null
      createTime?: string | null
      updateTime?: string | null
    }

    export interface HistoryRecord {
      id?: number | null
      name?: string | null
      createId?: number | null
      updateId?: number | null
      createName?: string | null
      updateName?: string | null
      createTime?: string | null
      updateTime?: string | null
      detailList?: Array<HistoryDetail> | null
    }

    export interface RecordPage {
      currentPage?: number | null
      pageSize?: number | null
      total?: number | null
      pages?: number | null
      cacheKey?: string | null
      records?: Array<HistoryRecord> | null
    }

    export interface TemplateQuestionSet {
      questions: Array<string>
    }

    #{arkts_enum("FunctionName", names).rstrip}

    #{arkts_function_name_from_raw_switch(names).rstrip}

    export enum FunctionArgumentKind {
      Basic = 'basic',
      TimeRange = 'timeRange',
      Warehouse = 'warehouse',
      AccountAge = 'accountAge',
      PerformanceType = 'performanceType'
    }

    #{arkts_function_argument_kind_switch(names).rstrip}

    export interface BasicQuery {
      orgId?: number | null
      customerName?: string | null
      orderType?: string | null
      operator?: string | null
      value?: number | null
    }

    export interface TimeRangeQuery extends BasicQuery {
      startDate?: string | null
      endDate?: string | null
      goodsType?: number | null
    }

    export interface WarehouseQuery {
      orgId?: number | null
      warehouseName?: string | null
      goodsType?: number | null
      orderType?: string | null
      operator?: string | null
      value?: number | null
    }

    export interface AccountAgeQuery {
      orgId?: number | null
      customerName?: string | null
      orderType?: string | null
      valueArray?: Array<string> | null
    }

    export interface PerformanceTypeQuery {
      indexType?: string | null
    }

    export interface FunctionArguments {
      kind: FunctionArgumentKind
      basic?: BasicQuery | null
      timeRange?: TimeRangeQuery | null
      warehouse?: WarehouseQuery | null
      accountAge?: AccountAgeQuery | null
      performanceType?: PerformanceTypeQuery | null
    }

    export interface FunctionModel {
      historyId?: number | null
      hasTool?: boolean | null
      name?: FunctionName | null
      msg?: string | null
      arguments?: FunctionArguments | null
    }

    export interface ChartCommonItem {
      bizId?: string | null
      name?: string | null
      value?: number | null
    }

    export interface AccountAgeGroupItem {
      name?: string | null
      valueList?: Array<number> | null
      labelList?: Array<string> | null
      msg?: string | null
      chartType?: string | null
    }

    export interface HistoryChartDetail {
      funcType?: FunctionName | null
      chartCommonVoList?: Array<ChartCommonItem> | null
      accountAgeGroupVoList?: Array<AccountAgeGroupItem> | null
    }

    export enum ConversationRole {
      User = 'user',
      Assistant = 'assistant'
    }

    export enum ConversationContentKind {
      Welcome = 'welcome',
      Text = 'text',
      Intent = 'intent',
      Chart = 'chart'
    }

    export enum AIChatIntentType {
      Time = 'time',
      Index = 'index'
    }

    export enum FeedbackState {
      Liked = 'liked',
      Disliked = 'disliked',
      None = 'none',
      Unknown = 'unknown'
    }

    export enum ChartUnit {
      Currency = 'currency',
      Ton = 'ton'
    }

    export interface ChartSeries {
      xAxis: string
      labels: Array<string>
      values: Array<number>
    }

    export interface ChartPayload {
      functionName?: FunctionName | null
      unit: ChartUnit
      series: Array<ChartSeries>
      emptyMessage?: string | null
    }

    export interface ConversationMessage {
      id: string
      role: ConversationRole
      contentKind: ConversationContentKind
      text?: string | null
      intentType?: AIChatIntentType | null
      chartPayload?: ChartPayload | null
      feedback: FeedbackState
      historyDetailId?: number | null
      functionName?: FunctionName | null
    }
  ARKTS
end

def source_files
  Dir.glob(File.join(CONTRACTS_DIR, "**/*.{json,yaml}"))
    .reject { |path| path == MANIFEST_OUTPUT }
    .sort
end

def manifest
  files = source_files.map do |path|
    {
      "path" => path.sub("#{ROOT}/", ""),
      "sha256" => Digest::SHA256.file(path).hexdigest
    }
  end
  source_hash = Digest::SHA256.hexdigest(files.map { |file| "#{file.fetch("path")}:#{file.fetch("sha256")}" }.join("\n"))

  {
    "generator" => "scripts/generate-cross-platform-contracts.rb",
    "sourceHash" => source_hash,
    "outputs" => [
      ANDROID_OUTPUT.sub("#{ROOT}/", ""),
      WEB_OUTPUT.sub("#{ROOT}/", ""),
      HARMONY_OUTPUT.sub("#{ROOT}/", "")
    ],
    "sources" => files
  }
end

def write_file(path, content)
  FileUtils.mkdir_p(File.dirname(path))
  File.write(path, content)
end

unless system(RbConfig.ruby, File.join(ROOT, "scripts/validate-cross-platform-contracts.rb"))
  abort "Contract validation failed; generation stopped."
end

write_file(ANDROID_OUTPUT, kotlin_models)
write_file(WEB_OUTPUT, typescript_models)
write_file(HARMONY_OUTPUT, arkts_models)
write_file(MANIFEST_OUTPUT, JSON.pretty_generate(manifest) + "\n")

puts "Generated #{ANDROID_OUTPUT.sub("#{ROOT}/", "")}"
puts "Generated #{WEB_OUTPUT.sub("#{ROOT}/", "")}"
puts "Generated #{HARMONY_OUTPUT.sub("#{ROOT}/", "")}"
puts "Generated #{MANIFEST_OUTPUT.sub("#{ROOT}/", "")}"
