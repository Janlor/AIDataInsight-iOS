import { ReactNode } from 'react';

export function PageHeader({
  title,
  description,
  action,
}: {
  title: string;
  description?: string;
  action?: ReactNode;
}) {
  return (
    <div className="mb-6 flex flex-col gap-4 sm:flex-row sm:items-end sm:justify-between">
      <div>
        <h1 className="text-2xl font-semibold tracking-normal text-label-primary">{title}</h1>
        {description ? <p className="mt-2 text-sm leading-6 text-label-secondary">{description}</p> : null}
      </div>
      {action}
    </div>
  );
}
