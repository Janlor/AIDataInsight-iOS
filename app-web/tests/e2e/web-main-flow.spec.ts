import { expect, test } from '@playwright/test';

test.beforeEach(async ({ page }) => {
  await page.goto('/login');
  await page.evaluate(() => window.localStorage.clear());
  await page.reload();
});

test('logs in, sends a chart question, and manages history', async ({ page }) => {
  await page.getByLabel('账号').fill('demo');
  await page.getByLabel('密码').fill('demo@123');
  await page.getByLabel(/我已阅读并同意/).check();
  await page.getByRole('button', { name: '登录' }).click();

  await expect(page.getByRole('heading', { name: 'AI 工作台' })).toBeVisible();

  await page.getByPlaceholder('输入你想分析的问题').fill('查看一月销售额');
  await page.getByRole('button', { name: '发送' }).click();

  await expect(page.getByText('图表结果')).toBeVisible();
  await expect(page.getByText('2026-01')).toBeVisible();

  await page.getByRole('link', { name: '历史' }).click();
  await expect(page.getByRole('heading', { name: '历史记录' })).toBeVisible();
  await expect(page.getByRole('link', { name: '查看一月销售额' })).toBeVisible();

  await page.getByRole('button', { name: '删除历史' }).first().click();
  await expect(page.getByRole('link', { name: '你好' })).toHaveCount(0);

  await page.getByRole('button', { name: '清空' }).click();
  await expect(page.getByText('暂无历史记录')).toBeVisible();
});
