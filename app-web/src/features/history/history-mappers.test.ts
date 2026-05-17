import { describe, expect, it } from 'vitest';
import type { RecordPage } from '@/contracts/generated/models';
import { mapRecordPageToSections } from './history-mappers';

describe('history mappers', () => {
  it('groups history records into today, this month, and other sections', () => {
    const page: RecordPage = {
      records: [
        { id: 1001, name: '查看今年销售情况', updateTime: '2026-05-17 09:30:00' },
        { id: 1002, name: '煤炭库存分析', updateTime: '2026-05-12 18:00:00' },
        { id: 1003, name: '年度经营指标', updateTime: '2025-12-30 08:00:00' },
      ],
    };

    const sections = mapRecordPageToSections(page, new Date('2026-05-17T12:00:00'));

    expect(sections).toEqual([
      {
        kind: 'today',
        title: '今天',
        items: [{ id: '1001', title: '查看今年销售情况', displayTime: '09:30' }],
      },
      {
        kind: 'thisMonth',
        title: '本月',
        items: [{ id: '1002', title: '煤炭库存分析', displayTime: '05-12' }],
      },
      {
        kind: 'other',
        title: '其它',
        items: [{ id: '1003', title: '年度经营指标', displayTime: '2025-12-30' }],
      },
    ]);
  });
});
