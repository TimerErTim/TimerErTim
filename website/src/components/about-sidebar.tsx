import { routes } from "@/paths";
import { contact } from "@/site/contact";

function telHref(phone: string): string {
  return `tel:${phone.replace(/\s/g, "")}`;
}

export function AboutSidebar() {
  return (
    <div className="flex h-fit max-h-full flex-col overflow-hidden bg-surface border border-border p-4">
      <h2 className="shrink-0 text-small leading-small font-semibold text-foreground m-0 mb-4">
        Contact
      </h2>
      <dl className="m-0 flex flex-col gap-3 text-small leading-small">
        <div>
          <dt className="text-muted m-0">Email</dt>
          <dd className="m-0 mt-1">
            <a
              className="text-foreground no-underline hover:text-accent hover:underline"
              href={`mailto:${contact.email}`}
            >
              {contact.email}
            </a>
          </dd>
        </div>
        <div>
          <dt className="text-muted m-0">Phone</dt>
          <dd className="m-0 mt-1">
            <a
              className="text-foreground no-underline hover:text-accent hover:underline"
              href={telHref(contact.phone)}
            >
              {contact.phone}
            </a>
          </dd>
        </div>
      </dl>

      <div className="mt-6 border-t border-border pt-4">
        <a
          className="text-small leading-small text-foreground underline-offset-2 hover:text-accent hover:underline"
          href={routes.cvPdf()}
          rel="noopener noreferrer"
          target="_blank"
        >
          Lebenslauf (PDF)
        </a>
      </div>
    </div>
  );
}
