import type { ChartPayload } from '@/contracts/generated/models';

export function ChartMessage({ payload }: { payload: ChartPayload | null | undefined }) {
  const series = payload?.series ?? [];

  if (series.length === 0) {
    return (
      <p className="mt-2 text-label-secondary">{payload?.emptyMessage ?? '暂无图表数据'}</p>
    );
  }

  return (
    <div className="mt-3 space-y-3">
      {series.map((item) => {
        const maxValue = Math.max(...item.values.map((value) => Math.abs(value)), 1);
        return (
          <div key={item.xAxis} className="rounded-control bg-surface-primary p-3">
            <p className="font-medium text-label-primary">{item.xAxis}</p>
            <div className="mt-3 space-y-2">
              {item.labels.map((label, index) => {
                const value = item.values[index] ?? 0;
                const width = Math.max(6, Math.round((Math.abs(value) / maxValue) * 100));
                return (
                  <div key={`${item.xAxis}-${label}`} className="grid grid-cols-[96px_1fr_auto] items-center gap-3">
                    <span className="truncate text-xs text-label-secondary">{label}</span>
                    <span className="h-2 overflow-hidden rounded-full bg-surface-tertiary">
                      <span
                        className="block h-full rounded-full bg-accent-primary"
                        style={{ width: `${width}%` }}
                      />
                    </span>
                    <span className="text-xs font-medium text-label-primary">{formatNumber(value)}</span>
                  </div>
                );
              })}
            </div>
          </div>
        );
      })}
    </div>
  );
}

function formatNumber(value: number): string {
  return new Intl.NumberFormat('zh-CN', {
    maximumFractionDigits: 2,
  }).format(value);
}
