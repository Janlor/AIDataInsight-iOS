'use client';

import { useEffect } from 'react';
import { useI18nStore } from './i18n-store';

export const dictionaries = {
  'zh-Hans': {
    brandTitle: 'AI数据分析助手',
    login: {
      slogan: '让工作更流畅更轻松',
      description: '让工作更流畅更轻松。用自然语言查询业绩、库存、代采、应收和账龄数据，快速生成清晰的经营分析结果。',
      formHelp: '使用账号进入 AI 数据分析工作台',
      username: '账号',
      password: '密码',
      privacyPrefix: '我已阅读并同意',
      privacyPolicy: '隐私协议',
      submit: '登录',
      submitting: '登录中…',
      missingCredentials: '请输入账号和密码',
      missingPrivacy: '请先阅读并同意隐私协议',
      failed: '登录失败，请稍后重试',
    },
    shell: {
      restoringSession: '正在恢复会话...',
      newChat: 'New Chat',
      settings: '设置',
      mobileBrand: 'AIDataInsight',
    },
    sidebar: {
      loadingHistory: '正在加载历史...',
      historyError: '历史加载失败',
      emptyHistory: '暂无历史记录',
      deleteHistory: '删除历史：{title}',
      openSettings: '打开设置：{name}',
      accountSubtitle: '设置与账户',
      sections: {
        today: '今天',
        thisMonth: '本月',
        other: '其它',
      },
    },
    ai: {
      loading: '正在加载 AI 工作台...',
      promptTitle: '今天想分析什么？',
      promptDescription: '选择一个推荐问题，或直接输入你的经营分析需求。',
      loadingQuestions: '正在加载推荐问题...',
      questionError: '推荐问题加载失败，已显示默认问题。',
      restoringHistory: '正在恢复历史会话...',
      analyzing: '正在分析...',
      inputPlaceholder: '输入你想分析的问题',
      send: '发送',
      chartResult: '图表结果',
      intentFallback: '已识别分析意图。',
      liked: '喜欢',
      disliked: '不喜欢',
      defaultQuestions: ['本月销售额按月份汇总', '库存按仓库分布', '应收账款账龄分析'],
    },
    history: {
      title: '历史记录',
      description: '已接入 history/page 数据层，详情恢复会复用 AI Chat 的 history mapper。',
      clear: '清空',
      loadingTitle: '正在加载历史记录',
      loadingDescription: '请稍候。',
      errorTitle: '历史记录加载失败',
      errorDescription: '请检查登录态或网络环境。当前接口层已经按跨端契约保留业务错误码。',
      emptyTitle: '暂无历史记录',
      emptyDescription: '完成一次 AI 对话后，会在这里显示历史会话。',
      delete: '删除历史',
    },
    setting: {
      title: '设置',
      close: '关闭设置',
      sections: {
        account: '账户',
        about: '关于',
        logout: null,
        language: '语言',
      },
      rows: {
        nickname: '昵称',
        username: '登录名',
        phone: '手机号',
        privacy: '隐私政策',
        appVersion: 'App版本',
        logout: '退出登录',
      },
      unset: '未设置',
      language: '语言',
      simplifiedChinese: '简体中文',
      english: 'English',
      confirmLogoutTitle: '确认注销并退出系统吗？',
      cancel: '取消',
      confirm: '确定',
    },
    privacy: {
      title: '隐私政策',
      updatedAtLabel: '更新日期',
      returnWorkspace: '返回工作台',
      returnLogin: '返回登录',
      sections: [
        {
          heading: '我们如何使用数据',
          paragraphs: [
            'AIDataInsight Web 端仅在登录、会话恢复、经营分析问答、历史记录和设置展示所需范围内处理账号信息与业务数据。',
            '账号信息用于识别当前用户、维持登录态和展示设置页账户信息；经营分析问题和返回结果用于完成用户主动发起的数据分析请求。',
          ],
        },
        {
          heading: '跨端一致性',
          paragraphs: [
            '隐私政策入口、登录勾选规则、设置页隐私入口和退出登录行为应与 iOS、Android、HarmonyOS NEXT 保持一致。',
            '各端实现可以采用页面、弹层或系统导航承载隐私政策，但展示文案和用户可访问性必须以跨平台契约为准。',
          ],
        },
        {
          heading: '本地与 Mock 环境',
          paragraphs: [
            '开发环境支持本地 mock 与 Apifox mock。Mock 数据仅用于开发调试，不代表正式生产数据处理规则。',
            '切换环境时应通过环境变量配置 API Base URL，不应在页面逻辑中硬编码隐私相关行为。',
          ],
        },
        {
          heading: '用户控制',
          paragraphs: [
            '用户可以在设置中查看隐私政策并退出登录。退出登录后，本端会清理受保护的会话状态并返回登录入口。',
            '未登录用户也可以从登录页访问隐私政策。',
          ],
        },
      ],
    },
    chart: {
      empty: '暂无图表数据',
    },
    common: {
      unknownUser: '已登录用户',
    },
  },
  en: {
    brandTitle: 'AI Data Insight',
    login: {
      slogan: 'Make Work Smoother and Easier',
      description: 'Make Work Smoother and Easier. Ask about sales, inventory, procurement, receivables, and aging in natural language, then get clear business insights quickly.',
      formHelp: 'Sign in to the AI data analysis workspace',
      username: 'Account',
      password: 'Password',
      privacyPrefix: 'I have read and agree to the',
      privacyPolicy: 'Privacy Policy',
      submit: 'Login',
      submitting: 'Logging in…',
      missingCredentials: 'Please enter your account and password',
      missingPrivacy: 'Please read and agree to the Privacy Policy first',
      failed: 'Login failed. Please try again later.',
    },
    shell: {
      restoringSession: 'Restoring session...',
      newChat: 'New Chat',
      settings: 'Settings',
      mobileBrand: 'AIDataInsight',
    },
    sidebar: {
      loadingHistory: 'Loading history...',
      historyError: 'Failed to load history',
      emptyHistory: 'No history yet',
      deleteHistory: 'Delete history: {title}',
      openSettings: 'Open settings: {name}',
      accountSubtitle: 'Settings and account',
      sections: {
        today: 'Today',
        thisMonth: 'This Month',
        other: 'Others',
      },
    },
    ai: {
      loading: 'Loading AI workspace...',
      promptTitle: 'What would you like to analyze today?',
      promptDescription: 'Choose a suggested question or type your own business analysis request.',
      loadingQuestions: 'Loading suggested questions...',
      questionError: 'Failed to load suggestions. Showing default questions.',
      restoringHistory: 'Restoring history conversation...',
      analyzing: 'Analyzing...',
      inputPlaceholder: 'Enter your analysis question',
      send: 'Send',
      chartResult: 'Chart Result',
      intentFallback: 'Analysis intent recognized.',
      liked: 'Like',
      disliked: 'Dislike',
      defaultQuestions: ['Summarize sales by month', 'Show inventory by warehouse', 'Analyze receivables aging'],
    },
    history: {
      title: 'History',
      description: 'History data is connected and detail restore reuses the AI Chat history mapper.',
      clear: 'Clear',
      loadingTitle: 'Loading history',
      loadingDescription: 'Please wait.',
      errorTitle: 'Failed to load history',
      errorDescription: 'Check your session or network. Business error codes are preserved by the API layer.',
      emptyTitle: 'No history yet',
      emptyDescription: 'Your AI conversations will appear here after you complete one.',
      delete: 'Delete history',
    },
    setting: {
      title: 'Settings',
      close: 'Close settings',
      sections: {
        account: 'Account',
        about: 'About',
        logout: null,
        language: 'Language',
      },
      rows: {
        nickname: 'Nickname',
        username: 'Login Name',
        phone: 'Phone',
        privacy: 'Privacy Policy',
        appVersion: 'App Version',
        logout: 'Log Out',
      },
      unset: 'Not set',
      language: 'Language',
      simplifiedChinese: '简体中文',
      english: 'English',
      confirmLogoutTitle: 'Log out and exit the system?',
      cancel: 'Cancel',
      confirm: 'Confirm',
    },
    privacy: {
      title: 'Privacy Policy',
      updatedAtLabel: 'Updated',
      returnWorkspace: 'Back to Workspace',
      returnLogin: 'Back to Login',
      sections: [
        {
          heading: 'How We Use Data',
          paragraphs: [
            'AIDataInsight Web processes account information and business data only for sign-in, session restore, business analysis, history, and settings display.',
            'Account information identifies the current user and keeps the session active. Analysis questions and results are used to complete requests initiated by the user.',
          ],
        },
        {
          heading: 'Cross-Platform Consistency',
          paragraphs: [
            'Privacy entry points, login agreement rules, settings access, and logout behavior should remain consistent across iOS, Android, HarmonyOS NEXT, and Web.',
            'Each platform may present this policy as a page, modal, or native navigation surface, but the copy and accessibility must follow the shared contract.',
          ],
        },
        {
          heading: 'Local and Mock Environments',
          paragraphs: [
            'Development supports local mock and Apifox mock. Mock data is only for development and debugging, and does not represent production data processing rules.',
            'Environment changes should be handled through API base URL configuration, not hard-coded privacy behavior in page logic.',
          ],
        },
        {
          heading: 'User Control',
          paragraphs: [
            'Users can view the Privacy Policy in Settings and log out. After logout, protected session state is cleared and the login entry is shown.',
            'Unauthenticated users can also open the Privacy Policy from the login page.',
          ],
        },
      ],
    },
    chart: {
      empty: 'No chart data',
    },
    common: {
      unknownUser: 'Signed-in user',
    },
  },
} as const;

export type I18nDictionary = typeof dictionaries['zh-Hans'];

export function useI18n() {
  const locale = useI18nStore((state) => state.locale);
  const hydrate = useI18nStore((state) => state.hydrate);
  const setLocale = useI18nStore((state) => state.setLocale);

  useEffect(() => {
    hydrate();
  }, [hydrate]);

  useEffect(() => {
    document.documentElement.lang = locale === 'en' ? 'en' : 'zh-Hans';
  }, [locale]);

  return {
    locale,
    setLocale,
    t: dictionaries[locale],
  };
}

export function interpolate(template: string, values: Record<string, string>) {
  return Object.entries(values).reduce(
    (current, [key, value]) => current.replaceAll(`{${key}}`, value),
    template,
  );
}
