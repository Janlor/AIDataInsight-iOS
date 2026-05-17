import { expect, test } from '@playwright/test';
import type { Page } from '@playwright/test';

test.beforeEach(async ({ page }) => {
  await page.goto('/login');
  await page.evaluate(() => window.localStorage.clear());
  await page.reload();
});

async function login(page: Page) {
  await page.getByLabel('账号').fill('demo');
  await page.getByLabel('密码').fill('demo@123');
  await page.getByLabel(/我已阅读并同意/).check();
  await page.getByRole('button', { name: '登录' }).click();
  await expect(page.getByRole('link', { name: 'New Chat' })).toBeVisible();
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
  await page.getByRole('button', { name: '删除历史' }).first().click();
  await expect(main.getByRole('link', { name: '你好', exact: true })).toHaveCount(0);

  await page.getByRole('button', { name: '清空' }).click();
  await expect(main.getByText('暂无历史记录')).toBeVisible();
});
