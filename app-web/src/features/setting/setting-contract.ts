import {
  settingInitialUiState,
  type AccountSession,
  type AccountUser,
  type SettingRow,
  type SettingUiState,
} from '@/contracts/generated/models';

const contractState = settingInitialUiState;
const unsetText = '未设置';

export function buildSettingStateFromContract({
  session,
  user,
}: {
  session: AccountSession;
  user: AccountUser | null;
}): SettingUiState {
  return {
    ...contractState,
    sections: contractState.sections.map((section) => ({
      ...section,
      rows: section.rows.map((row) => hydrateAccountRow(row, session, user)),
    })),
    logoutDialog: {
      ...contractState.logoutDialog,
      visible: false,
    },
  };
}

export function getDisplayName(session: AccountSession, user: AccountUser | null) {
  return user?.nickname ?? user?.username ?? session.username ?? '已登录用户';
}

export function getInitials(name: string) {
  const parts = name
    .trim()
    .split(/\s+/)
    .filter(Boolean);

  if (parts.length >= 2) {
    return `${parts[0][0] ?? ''}${parts[1][0] ?? ''}`.toUpperCase();
  }

  return name.trim().slice(0, 2).toUpperCase() || 'AI';
}

function hydrateAccountRow(row: SettingRow, session: AccountSession, user: AccountUser | null): SettingRow {
  if (row.kind === 'nickname') {
    return { ...row, detail: user?.nickname ?? unsetText };
  }

  if (row.kind === 'username') {
    return { ...row, detail: user?.username ?? session.username ?? unsetText };
  }

  if (row.kind === 'phone') {
    return { ...row, detail: user?.phone ?? unsetText };
  }

  return row;
}
