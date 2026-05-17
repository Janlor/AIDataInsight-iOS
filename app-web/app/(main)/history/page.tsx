import { PageHeader } from '@/components/page-header';
import { StatusPanel } from '@/components/status-panel';

export default function HistoryPage() {
  return (
    <>
      <PageHeader
        title="历史记录"
        description="历史分页、删除和详情恢复将在 AI Chat 网络用例之后接入。"
      />
      <StatusPanel
        title="历史模块待接入"
        description="页面入口已完成，会话守卫已生效。下一步会基于 contract fixtures 接入 history/page 和 history/detail。"
      />
    </>
  );
}
