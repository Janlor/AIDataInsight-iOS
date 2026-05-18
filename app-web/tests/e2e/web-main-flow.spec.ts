import { expect, test } from '@playwright/test';
import type { Page } from '@playwright/test';

test.beforeEach(async ({ page }) => {
  await page.goto('/login');
  await page.evaluate(() => window.localStorage.clear());
  await page.evaluate(() => window.localStorage.setItem('aidatainsight.locale', 'zh-Hans'));
  await page.reload();
});

test('shows localized login brand content', async ({ page }) => {
  await expect(page.getByRole('img', { name: 'AI数据分析助手' })).toBeVisible();
  await expect(page.getByRole('heading', { name: 'AI数据分析助手' })).toBeVisible();
  await expect(page.getByText('让工作更流畅更轻松')).toBeVisible();
});

test('switches login content to English', async ({ page }) => {
  await page.evaluate(() => window.localStorage.setItem('aidatainsight.locale', 'en'));
  await page.reload();

  await expect(page.getByRole('img', { name: 'AI Data Insight' })).toBeVisible();
  await expect(page.getByRole('heading', { name: 'AI Data Insight' })).toBeVisible();
  await expect(page.getByText('Make Work Smoother and Easier')).toBeVisible();
  await expect(page.getByLabel('Account')).toBeVisible();
});

async function login(page: Page) {
  await page.getByLabel('账号').fill('demo');
  await page.getByLabel('密码').fill('demo@123');
  await page.getByLabel(/我已阅读并同意/).check();
  await page.getByRole('button', { name: '登录' }).click();
  await expect(page.getByRole('link', { name: '新聊天' })).toBeVisible();
  await expect(page.getByRole('heading', { name: 'AI数据分析助手' })).toBeVisible();
}

test('opens contract-driven settings from the sidebar account entry', async ({ page }) => {
  await login(page);

  await page.getByRole('button', { name: /打开设置/ }).click();
  const dialog = page.getByRole('dialog', { name: '设置' });
  await expect(dialog).toBeVisible();
  await expect(dialog.getByText('账户')).toBeVisible();
  await expect(dialog.getByText('昵称')).toBeVisible();
  await expect(dialog.getByText('登录名')).toBeVisible();
  await expect(dialog.getByText('隐私政策')).toBeVisible();
  await expect(dialog.getByText('App版本')).toBeVisible();
  await expect(dialog.getByRole('button', { name: '退出登录' })).toBeVisible();
});

test('opens privacy policy from settings without returning authenticated users to login', async ({ page }) => {
  await login(page);

  await page.getByRole('button', { name: /打开设置/ }).click();
  await page.getByRole('link', { name: /隐私政策/ }).click();

  await expect(page).toHaveURL(/\/privacy/);
  await expect(page.getByRole('heading', { name: '隐私政策', level: 1 })).toBeVisible();
  await expect(page.getByText('AIDataInsight Web 端仅在登录')).toBeVisible();
  await expect(page.getByRole('link', { name: '返回工作台' })).toBeVisible();
  await expect(page.getByRole('link', { name: '返回登录' })).toHaveCount(0);
});

test('deletes a history conversation from the sidebar', async ({ page }) => {
  await login(page);

  await expect(page.getByRole('link', { name: /你好/ })).toBeVisible();
  await page.getByRole('button', { name: '删除历史：你好' }).click();
  await expect(page.getByRole('link', { name: /你好/ })).toHaveCount(0);
});

test('starts a fresh new chat from an existing new chat draft', async ({ page }) => {
  await login(page);

  await page.getByPlaceholder('输入你想分析的问题').fill('你好');
  await page.getByRole('button', { name: '发送' }).click();
  await expect(page.getByText('你好，我可以帮你分析经营数据。').last()).toBeVisible();

  await page.getByRole('link', { name: '新聊天' }).click();
  await expect(page).toHaveURL(/newChat=/);
  await expect(page.getByRole('heading', { name: '今天想分析什么？' })).toBeVisible();
  await expect(page.getByText('你好，我可以帮你分析经营数据。')).toHaveCount(0);
});

test('logs in, sends a chart question, and restores history from the sidebar', async ({ page }) => {
  await login(page);

  await expect(page.getByRole('heading', { name: '今天想分析什么？' })).toBeVisible();
  await expect(page.getByRole('button', { name: '今年第三季度销售额大于2亿的公司有哪些？' })).toBeVisible();

  await page.getByPlaceholder('输入你想分析的问题').fill('查看一月销售额');
  await page.getByRole('button', { name: '发送' }).click();

  await expect(page.getByText('图表结果')).toBeVisible();
  await expect(page.getByText('2026-01').first()).toBeVisible();

  await page.getByRole('link', { name: /查看一月销售额/ }).click();
  await expect(page).toHaveURL(/historyId=123/);
  await expect(page.getByText('查看一月销售额').last()).toBeVisible();
  await expect(page.getByText('图表结果')).toBeVisible();
});

test('manages history from the history route', async ({ page }) => {
  await login(page);

  await page.goto('/history');
  const main = page.locator('main');
  await expect(main.getByRole('heading', { name: '历史记录', exact: true })).toBeVisible();
  await expect(main.getByRole('link', { name: '查看一月销售额', exact: true })).toBeVisible();
  await main.getByRole('button', { name: '删除历史' }).first().click();
  await expect(main.getByRole('link', { name: '你好', exact: true })).toHaveCount(0);

  await main.getByRole('button', { name: '清空' }).click();
  await expect(main.getByText('暂无历史记录')).toBeVisible();
});
