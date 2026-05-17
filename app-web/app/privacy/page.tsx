import Link from 'next/link';

export default function PrivacyPage() {
  return (
    <main className="min-h-screen bg-surface-secondary px-4 py-8">
      <article className="mx-auto max-w-3xl rounded-lg border border-separator bg-white p-6 shadow-sm">
        <h1 className="text-2xl font-semibold text-label-primary">隐私协议</h1>
        <p className="mt-4 text-sm leading-7 text-label-secondary">
          当前 Web 端隐私协议页面为占位实现。正式内容应从跨平台 Privacy 契约或后端配置接入，
          并与 iOS、Android、HarmonyOS NEXT 的协议展示规则保持一致。
        </p>
        <div className="mt-6">
          <Link
            className="inline-flex h-10 items-center rounded-control bg-accent-primary px-4 text-sm font-medium text-white"
            href="/login"
          >
            返回登录
          </Link>
        </div>
      </article>
    </main>
  );
}
